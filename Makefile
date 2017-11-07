TARGET=libfoo.so

.PHONY: clean

$(TARGET): foo.c
	gcc -fPIC -shared -Wall -o $@ $^

clean:
	rm -fR $(TARGET)
