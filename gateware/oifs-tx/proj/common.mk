
all: $(PROJ).timing.rpt $(PROJ).bin

%.json: $(VSRC)
	yosys -l $*.synth.rpt -p \
		'synth_ice40 $(EXTRA_OPT) -top $(TOP) -json $@' \
		$(VSRC)

%.asc: $(PCF) %.json
	nextpnr-ice40 --$(DEVICE) \
		$(if $(PACKAGE),--package $(PACKAGE)) \
		$(if $(FREQ),--freq $(FREQ)) \
		--json $(filter-out $<,$^)     \
		-l $*.pnr.rpt \
		--pcf $< --asc $@

%.bin: %.asc
	icepack $< $@

%.timing.rpt: %.asc
	icetime $(if $(FREQ),-c $(FREQ)) -d $(DEVICE) \
		-mtr $@ $<

prog: $(PROJ).bin
	iceprog -S -k $<

prog_flash: $(PROJ).bin
	iceprog $<

clean:
	rm -f $(PROJ).json $(PROJ).asc $(PROJ).bin *.rpt $(ADD_CLEAN)

.SECONDARY:
.PHONY: all prog prog_flash clean