soname = libruby-1.9.1.so.1.9
package = $(shell sed -n -e 's/Package: *// p' fakeruby.equivs)
version = $(shell sed -n -e 's/Version: *// p' fakeruby.equivs) 
debversion = $(lastword $(subst :, ,$(version)))

deb = $(package)_$(debversion)_all.deb

.PHONY: all
all: $(deb)


fakeruby.c: /usr/lib/$(soname)
	./genfakelib $(<) > $(@)+
	mv $(@)+ $(@)

$(soname): fakeruby.c
	$(CC) $(CFLAGS) $(CPPFLAGS) $(LDFLAGS) -shared -fPIC -Wl,-soname,$(soname) $(<) -o $(@)+
	strip --remove-section=.comment --remove-section=.note --strip-unneeded $(@)+
	mv $(@)+ $(@)

%.deb: fakeruby.equivs $(soname)
	equivs-build $(<)

.PHONY: clean
clean:
	rm -f *.c *.deb *.so.*

# vim:ts=4 sw=4 noet
