# Copyright 2011 by Untyped Ltd. All Rights Reserved\
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# No portion of this Software shall be used in any application which does not
# use the ReportGrid platform to provide some subset of its functionality.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#

require 'minitest/autorun'
require 'myna/future'

describe Future do
  describe "Future.map" do
    it "must run the given block and complete the returned future" do
      f1 = Future::Future.new
      f2 = f1.map do |v|
        v + 3
      end

      f1.succeed(1)
      f2.get.must_equal 4
    end

    it "must run the given block and complete the returned future from another thread" do
      f1 = Future::Future.new
      f2 = f1.map do |v|
        v + 3
      end

      Thread.new do
        sleep(1)
        f1.succeed(1)
      end

      f2.get.must_equal 4
    end
  end

  describe "Future.fail" do
    it "must cause an exception to be raised on get" do
      exn = Exception.new("A test")
      f = Future::Future.new
      f.fail(exn)

      proc { f.get }.must_raise Exception
    end
  end

  describe "Future.run" do
    it "must complete the future with the expected value" do
      f = Future.run do 1 + 1 end
      f.get.must_equal 2
    end

    it "must catch exceptions and complete the future in a failed state" do
      f = Future.run do 1/0 end
      proc { f.get }.must_raise ZeroDivisionError
    end
  end
end
