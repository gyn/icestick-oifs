PROJ := oifs_top

VSRC := ../rtl/oifs_top.v \
        ../rtl/pll.v \
        ../rtl/oifs.v \
        ../rtl/oifs_tx_interface.v \
        ../rtl/oifs_tx_controller.v

TOP  := $(PROJ)
EXTRA_OPT := -abc2
EXTRA_OPT += #-noflatten
EXTRA_OPT += #-device hx -abc9
EXTRA_OPT += #-dffe_min_ce_use 4
EXTRA_OPT += -dff

DEVICE  := hx1k
PACKAGE := tq144
FREQ    := 99
PCF     := icestick.pcf

ADD_CLEAN := abc.history

include common.mk