BASE_DIR         = $(shell pwd)
ERLANG_BIN       = $(shell dirname $(shell which erl))
GIT_VERSION      = $(shell git describe --tags --always)
OVERLAY_VARS    ?=
REBAR ?= $(BASE_DIR)/rebar3

$(if $(ERLANG_BIN),,$(warning "Warning: No Erlang found in your path, this will probably not work"))


all: compile

compile:
	$(REBAR) $(PROFILE) compile


rpi32: PROFILE = as rpi32
rpi32: rel

with_rocksdb: PROFILE = as rocksdb
with_rocksdb: rel

with_leveled: PROFILE = as leveled
with_leveled: rel

with_leveldb: PROFILE = as leveldb
with_leveldb: rel

with_all_backends: PROFILE = as with_all
with_all_backends: rel

##
## Release targets
##
rel:
	cat vars.config > vars.generated
	echo "{app_version, \"${GIT_VERSION}\"}." >> vars.generated
ifeq ($(OVERLAY_VARS),)
else
	echo "%% including OVERLAY_VARS from an additional file." >> vars.generated
	echo \"./${OVERLAY_VARS}\". >> vars.generated
endif
	$(REBAR) $(PROFILE) release

##
## Developer targets
##
##  devN - Make a dev build for node N
dev% :
	./gen_dev $@ vars/dev_vars.config.src vars/$@_vars.config
	cat vars/$@_vars.config > vars.generated
	(./rebar3 as $@ release)

.PHONY: all compile rpi32 rel
export OVERLAY_VARS
