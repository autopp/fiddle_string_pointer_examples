require 'fiddle/import'

module Foo
  extend Fiddle::Importer
  dlload './libfoo.so'
  extern 'char **get_strs_direct()'
  extern 'int get_strs_indirect(char ***ptr)'
end

def test(name)
  result = yield
  expected = %w[aaa bbb ccc ddd eee]
  if result == expected
    puts "#{name}: OK"
  else
    puts "#{name}: NG (got #{result.inspect})"
  end
end

size_of_ptr = Fiddle::SIZEOF_VOIDP
template = case size_of_ptr
           when 8
             'Q'
           when 4
             'L'
           when 2
             'S'
           else
             raise "unknown size of pointer #{size_of_ptr}"
           end

test('get_strs_direct') do
  result = []
  strs_ptr = Foo.get_strs_direct
  loop do
    # get head of pointers
    str_ptr = strs_ptr.to_s(size_of_ptr).unpack(template).first

    # str_ptr is zero => last element `NULL`
    break if str_ptr.zero?

    result << Fiddle::Pointer.new(str_ptr).to_s

    # shift by offset
    strs_ptr += size_of_ptr
  end
  result
end

test('get_strs_indirect') do
  # char ***ptr = malloc(sizeof(char **));
  ptr = "\0" * size_of_ptr
  size = Foo.get_strs_indirect(ptr)

  # char **strs_ptr = *ptr;
  strs_ptr = Fiddle::Pointer.new(ptr.unpack(template).first)

  strs_ptr.to_s(size_of_ptr * size).unpack("#{template}#{size}").map do |addr|
    Fiddle::Pointer.new(addr).to_s
  end
end
