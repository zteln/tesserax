CFLAGS = -fPIC -Wall -Wextra -Wno-unused-parameter

ERL_INCLUDE_PATH = $(shell erl -eval 'io:format("~s", [lists:concat([code:root_dir(), "/erts-", erlang:system_info(version), "/include"])])' -s init stop -noshell)

CFLAGS += -I$(ERL_INCLUDE_PATH)

TESSERACT_INCLUDE_PATH=$(TESSERACT_BASE_DIR)/include/
TESSERACT_LIB_PATH=$(TESSERACT_BASE_DIR)/lib/

CFLAGS += -L$(TESSERACT_LIB_PATH) \
		  -ltesseract \
		  -I$(TESSERACT_INCLUDE_PATH)

LEPTONICA_INCLUDE_PATH=$(LEPTONICA_BASE_DIR)/include/
LEPTONICA_LIB_PATH=$(LEPTONICA_BASE_DIR)/lib/

CFLAGS += -L$(LEPTONICA_LIB_PATH) \
		  -lleptonica \
		  -I$(LEPTONICA_INCLUDE_PATH)

ifeq ($(shell uname),Darwin)
	LDFLAGS += -dynamiclib -undefined dynamic_lookup
endif

all: priv/tesseract_api.so

priv/tesseract_api.so: src/tesseract_api.c
	$(CC) $(CFLAGS) \
		-shared $(LDFLAGS) \
		-o priv/tesseract_api.so \
		src/tesseract_api.c

clean:
	$(RM) priv/tesseract_api.so
