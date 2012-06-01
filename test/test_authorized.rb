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
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#

require 'minitest/autorun'
require 'myna'

describe Myna do

  before do
    Myna.run.get
  end

  module TestHost
    SCHEME = "http"
    HOST   = 'localhost'
    PORT   = 8080
  end

  describe "create and delete" do
    it "must return an Experiment and delete same experiment" do
      myna = Myna.authorize("test@example.com", "themostsecretpassword")

      expt = myna.create("dummy experimento").get
      expt.must_be_kind_of Myna::AuthorizedExperiment

      expt.delete().get.must_be_kind_of Response::Ok
    end
  end

  describe "create_variant and delete_variant" do
    it "must create and delete variants" do
      myna = Myna.authorize("test@example.com", "themostsecretpassword")

      expt = myna.create("dummy experimento").get

      expt.create_variant("An awesome variant").get.must_be_kind_of Response::Ok
      expt.delete_variant("An awesome variant").get.must_be_kind_of Response::Ok

      expt.delete().get.must_be_kind_of Response::Ok
    end
  end

  describe "info" do
    it "must return the expected info" do
      myna = Myna.authorize("test@example.com", "themostsecretpassword")

      info = myna.experiment('45923780-80ed-47c6-aa46-15e2ae7a0e8c').info().get

      info.must_be_kind_of Response::Experiment
      info.name.must_equal "test"
      info.uuid.must_equal '45923780-80ed-47c6-aa46-15e2ae7a0e8c'
      info.variants.length.must_equal 2
      info.variants[0].name.must_equal 'variant1'
      info.variants[1].name.must_equal 'variant2'
    end
  end
end
