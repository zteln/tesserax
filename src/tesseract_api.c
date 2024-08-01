#include <erl_nif.h>
#include <leptonica/allheaders.h>
#include <tesseract/capi.h>

#include <stdbool.h>
#include <string.h>

#define MAX_BUF_LEN 1024

typedef struct {
  ERL_NIF_TERM atom_image;
  ERL_NIF_TERM atom_languages;
  ERL_NIF_TERM atom_tessdata;
  ERL_NIF_TERM atom_config;
  ERL_NIF_TERM atom_psm;
  ERL_NIF_TERM atom_oem;
} tesserax_priv;

static ERL_NIF_TERM error_tuple(ErlNifEnv *env, const char *error) {
  return enif_make_tuple2(env, enif_make_atom(env, "error"),
                          enif_make_atom(env, error));
}

static ERL_NIF_TERM ok_tuple(ErlNifEnv *env, ERL_NIF_TERM term) {
  return enif_make_tuple2(env, enif_make_atom(env, "ok"), term);
}

static void erlbinarycopy(char *text, ErlNifBinary *bin) {
  enif_alloc_binary(strlen(text), bin);
  strcpy((char *)bin->data, text);
  bin->size = strlen(text);
}

static void bufcopy(ErlNifEnv *env, char *buf, ERL_NIF_TERM term) {
  ErlNifBinary bin;
  enif_inspect_binary(env, term, &bin);
  strncpy(buf, (const char *)bin.data, bin.size + 1);
}

static ERL_NIF_TERM recognize(ErlNifEnv *env, ERL_NIF_TERM command,
                              PIX *image_reader(ErlNifEnv *env,
                                                ERL_NIF_TERM arg)) {
  tesserax_priv *priv;
  ERL_NIF_TERM enif_image;
  ERL_NIF_TERM enif_languages;
  ERL_NIF_TERM enif_tessdata;
  ERL_NIF_TERM enif_config;
  ERL_NIF_TERM enif_psm;
  ERL_NIF_TERM enif_oem;
  ERL_NIF_TERM output;
  ErlNifBinary enif_recognized_text_bin;
  TessBaseAPI *handle;
  PIX *image;
  char languages[MAX_BUF_LEN] = {"\0"};
  char tessdata[MAX_BUF_LEN] = {"\0"};
  char config[MAX_BUF_LEN] = {"\0"};
  char *text;
  enum TessPageSegMode psm = PSM_AUTO_ONLY;
  enum TessOcrEngineMode oem = OEM_DEFAULT;
  int configs_size = 0;

  priv = enif_priv_data(env);
  if (!enif_get_map_value(env, command, priv->atom_image, &enif_image))
    return error_tuple(env, "missing_image");

  if (!enif_get_map_value(env, command, priv->atom_languages,
                          &enif_languages)) {
    return error_tuple(env, "missing_languages");
  } else {
    bufcopy(env, languages, enif_languages);
  }

  if (enif_get_map_value(env, command, priv->atom_tessdata, &enif_tessdata))
    bufcopy(env, tessdata, enif_tessdata);

  if (enif_get_map_value(env, command, priv->atom_config, &enif_config))
    bufcopy(env, config, enif_config);

  if (enif_get_map_value(env, command, priv->atom_psm, &enif_psm))
    enif_get_uint(env, enif_psm, &psm);

  if (enif_get_map_value(env, command, priv->atom_oem, &enif_oem))
    enif_get_uint(env, enif_oem, &oem);

  if ((image = (*image_reader)(env, enif_image)) == NULL)
    return error_tuple(env, "invalid_image_input");

  if (strlen(config) != 0)
    configs_size = 1;

  char *configs[1];
  configs[0] = config;

  handle = TessBaseAPICreate();
  if (TessBaseAPIInit1(handle, tessdata, languages, oem, configs,
                       configs_size) != 0)
    return error_tuple(env, "failed_to_initialize_handle");

  TessBaseAPISetImage2(handle, image);
  TessBaseAPISetPageSegMode(handle, psm);

  if (TessBaseAPIRecognize(handle, NULL) != 0)
    return error_tuple(env, "failed_to_recognize");

  if ((text = TessBaseAPIGetUTF8Text(handle)) == NULL)
    return error_tuple(env, "failed_to_get_text");

  erlbinarycopy(text, &enif_recognized_text_bin);

  TessDeleteText(text);
  TessBaseAPIEnd(handle);
  TessBaseAPIDelete(handle);
  pixDestroy(&image);

  output = enif_make_binary(env, &enif_recognized_text_bin);

  enif_release_binary(&enif_recognized_text_bin);

  return ok_tuple(env, output);
}

static PIX *pix_read_mem(ErlNifEnv *env, ERL_NIF_TERM input) {
  ErlNifBinary image_bin;

  if (!enif_inspect_binary(env, input, &image_bin))
    return NULL;

  return pixReadMemPng(image_bin.data, image_bin.size);
}

static PIX *pix_read_file(ErlNifEnv *env, ERL_NIF_TERM input) {
  char buf[MAX_BUF_LEN];
  bufcopy(env, buf, input);
  return pixRead(buf);
}

static ERL_NIF_TERM run_mem(ErlNifEnv *env, int argc,
                            const ERL_NIF_TERM argv[]) {
  if (argc < 1)
    return enif_make_badarg(env);
  return recognize(env, argv[0], pix_read_mem);
}

static ERL_NIF_TERM run_file(ErlNifEnv *env, int argc,
                             const ERL_NIF_TERM argv[]) {
  if (argc < 1)
    return enif_make_badarg(env);
  return recognize(env, argv[0], pix_read_file);
}

static ERL_NIF_TERM list_languages(ErlNifEnv *env, int argc,
                                   const ERL_NIF_TERM argv[]) {
  if (argc < 1) {
    return enif_make_badarg(env);
  }
  tesserax_priv *priv;
  ERL_NIF_TERM output = enif_make_list(env, 0);
  ERL_NIF_TERM enif_tessdata;
  ErlNifBinary enif_lang_bin;
  TessBaseAPI *handle;
  char tessdata[MAX_BUF_LEN] = {"\0"};
  char **languages;
  char *lang;

  priv = enif_priv_data(env);
  if (enif_get_map_value(env, argv[0], priv->atom_tessdata, &enif_tessdata))
    bufcopy(env, tessdata, enif_tessdata);

  handle = TessBaseAPICreate();
  if (TessBaseAPIInit3(handle, tessdata, NULL) != 0)
    return error_tuple(env, "error_initializing_handle");

  languages = TessBaseAPIGetAvailableLanguagesAsVector(handle);

  int i = 0;
  while ((lang = languages[i]) != NULL) {
    erlbinarycopy(lang, &enif_lang_bin);
    output =
        enif_make_list_cell(env, enif_make_binary(env, &enif_lang_bin), output);
    i++;
  };

  enif_release_binary(&enif_lang_bin);

  enif_make_reverse_list(env, output, &output);
  return ok_tuple(env, output);
}

static ErlNifFunc funcs[] = {
    {"run_mem", 1, run_mem, ERL_NIF_DIRTY_JOB_CPU_BOUND},
    {"run_file", 1, run_file, ERL_NIF_DIRTY_JOB_CPU_BOUND},
    {"list_languages", 1, list_languages, ERL_NIF_DIRTY_JOB_CPU_BOUND}};

static int load(ErlNifEnv *env, void **priv, ERL_NIF_TERM info) {
  tesserax_priv *data = enif_alloc(sizeof(tesserax_priv));
  if (data == NULL) {
    return 1;
  }
  data->atom_image = enif_make_atom(env, "image");
  data->atom_languages = enif_make_atom(env, "languages");
  data->atom_tessdata = enif_make_atom(env, "tessdata");
  data->atom_config = enif_make_atom(env, "config");
  data->atom_psm = enif_make_atom(env, "psm");
  data->atom_oem = enif_make_atom(env, "oem");

  *priv = (void *)data;

  return 0;
}

static int reload(ErlNifEnv *env, void **priv, ERL_NIF_TERM info) { return 0; }

static int upgrade(ErlNifEnv *env, void **priv, void **old_priv,
                   ERL_NIF_TERM info) {
  return load(env, priv, info);
}

static void unload(ErlNifEnv *env, void *priv) {}

ERL_NIF_INIT(Elixir.Tesserax.NIF, funcs, &load, &reload, &upgrade, &unload)
