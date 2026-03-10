PREFIX ?= /usr

.PHONY: install uninstall

install:
	install -d $(DESTDIR)$(PREFIX)/bin
	install -Dm755 jcm-daemon $(DESTDIR)$(PREFIX)/bin/jcm-daemon
	install -Dm755 jcm $(DESTDIR)$(PREFIX)/bin/jcm
	install -d $(DESTDIR)$(PREFIX)/share/jcm
	cp *.qml $(DESTDIR)$(PREFIX)/share/jcm/

uninstall:
	rm -f $(DESTDIR)$(PREFIX)/bin/jcm-daemon
	rm -f $(DESTDIR)$(PREFIX)/bin/jcm
	rm -rf $(DESTDIR)$(PREFIX)/share/jcm
