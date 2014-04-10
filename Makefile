soname = $(shell sed -n -e 's/Soname: *// p' fakeruby.equivs)
package = $(shell sed -n -e 's/Package: *// p' fakeruby.equivs)
version = $(shell sed -n -e 's/Version: *// p' fakeruby.equivs) 
debversion = $(lastword $(subst :, ,$(version)))

deb = $(package)_$(debversion)_all.deb

.PHONY: all
all: $(deb)

DEB_HOST_MULTIARCH ?= $(shell dpkg-architecture -qDEB_HOST_MULTIARCH)

fakeruby.c: /usr/lib/$(DEB_HOST_MULTIARCH)/$(soname)
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
