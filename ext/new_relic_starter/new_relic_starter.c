#include <errno.h>
#include <fcntl.h>
#include <sys/file.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <unistd.h>
#include "new_relic_starter.h"

VALUE eError;

static void
latch_free(void *ptr)
{
    munmap(ptr, 1);
}

static size_t
latch_size(const void *ptr)
{
    return sysconf(_SC_PAGE_SIZE);
}

static const rb_data_type_t latch_data_type = {
    "latch",
    { NULL, latch_free, latch_size, },
    0, 0, RUBY_TYPED_FREE_IMMEDIATELY
};

static VALUE
latch_s_allocate(VALUE klass)
{
    return TypedData_Wrap_Struct(klass, &latch_data_type, 0);
}

static int
open_latch_file(const char *path)
{
    struct stat st;

    int fd = open(path, O_CREAT|O_RDWR, 0666);
    if (fd == -1) {
        rb_raise(eError, "failed to open file %s: %s", path, strerror(errno));
    }

    if (flock(fd, LOCK_EX) == -1) {
        int e = errno;
        close(fd);
        rb_raise(eError, "failed to acquire an advisory lock for %s: %s", path, strerror(e));
    }

    if (fstat(fd, &st) == -1) {
        int e = errno;
        close(fd);
        rb_raise(eError, "failed to get file status for %s: %s", path, strerror(e));
    }

    if (st.st_size == 0) {
        if (write(fd, "", 1) == -1) {
            int e = errno;
            close(fd);
            rb_raise(eError, "failed to write to file %s: %s", path, strerror(e));
        }
    }

    if (flock(fd, LOCK_UN) == -1) {
        int e = errno;
        close(fd);
        rb_raise(eError, "failed to release an advisory lock for %s: %s", path, strerror(e));
    }

    return fd;
}

/*
 * call-seq:
 *    NewRelic::Starter::Latch.new -> latch
 *    NewRelic::Starter::Latch.new(path) -> latch
 *
 * Returns a new {Latch} object.
 *
 * The state of the latch is stored in memory mapped by mmap(2) and shared with
 * a forked process.
 *
 * If +path+ is specified, the memory mapping is backed by the file and the
 * state of the latch is shared with other latches backed by the same file.
 *
 *    NewRelic::Starter::Latch.new #=> #<NewRelic::Starter::Latch:0x00007fbecb04f038>
 *    NewRelic::Starter::Latch.new("/path/to/latch") #=> #<NewRelic::Starter::Latch:0x00007fbec9808010>
 */
static VALUE
latch_initialize(int argc, VALUE *argv, VALUE self)
{
    int fd = -1;
    void *addr;

    char *path = rb_check_arity(argc, 0, 1) ? RSTRING_PTR(argv[0]) : NULL;
    if (path != NULL) {
        fd = open_latch_file(path);
    }

    addr = mmap(NULL, 1, PROT_READ|PROT_WRITE, (fd == -1 ? MAP_ANONYMOUS|MAP_SHARED : MAP_SHARED), fd, 0);
    if (addr == MAP_FAILED) {
        int e = errno;
        close(fd);
        rb_raise(eError, "failed to create mapping for latch: %s", strerror(e));
    }
    close(fd);

    DATA_PTR(self) = addr;

    return self;
}

static inline uint8_t *
check_latch(VALUE self)
{
      return rb_check_typeddata(self, &latch_data_type);
}

/*
 * call-seq:
 *    latch.open -> nil
 *
 * Opens the latch.
 *
 *    latch = NewRelic::Starter::Latch.new
 *    latch.opened? #=> false
 *    latch.open
 *    latch.opened? #=> true
 */
static VALUE
latch_open(VALUE self)
{
    uint8_t *l = check_latch(self);
    *l = 1;
    return Qnil;
}

/*
 * call-seq:
 *    latch.opened? -> boolean
 *
 * Returns true if the latch is opened.
 *
 *    latch = NewRelic::Starter::Latch.new
 *    latch.opened? #=> false
 *    latch.open
 *    latch.opened? #=> true
 */
static VALUE
latch_opened(VALUE self)
{
    return *check_latch(self) == 1 ? Qtrue : Qfalse;
}

void
Init_new_relic_starter(void)
{
    VALUE mNewRelic, cStarter, cLatch;

    mNewRelic = rb_define_module("NewRelic");
    cStarter = rb_define_class_under(mNewRelic, "Starter", rb_cObject);
    eError = rb_define_class_under(cStarter, "Error", rb_eStandardError);

    /*
     * Document-class: NewRelic::Starter::Latch
     *
     * NewRelic::Starter::Latch indicates whether the New Relic agent should be
     * started.
     */
    cLatch = rb_define_class_under(cStarter, "Latch", rb_cObject);
    rb_define_alloc_func(cLatch, latch_s_allocate);
    rb_define_method(cLatch, "initialize", latch_initialize, -1);
    rb_define_method(cLatch, "open", latch_open, 0);
    rb_define_method(cLatch, "opened?", latch_opened, 0);
}
