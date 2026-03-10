PREFIX ?= /usr

.PHONY: all install uninstall

all:
	@echo "Run 'sudo make install' to install JCM."

install:
	install -d $(DESTDIR)$(PREFIX)/bin
	install -Dm755 bin/jcm-daemon $(DESTDIR)$(PREFIX)/bin/jcm-daemon
	install -Dm755 bin/jcm $(DESTDIR)$(PREFIX)/bin/jcm
	install -d $(DESTDIR)$(PREFIX)/share/jcm
	cp -r qml $(DESTDIR)$(PREFIX)/share/jcm/

uninstall:
	rm -f $(DESTDIR)$(PREFIX)/bin/jcm-daemon
	rm -f $(DESTDIR)$(PREFIX)/bin/jcm
	rm -rf $(DESTDIR)$(PREFIX)/share/jcm
