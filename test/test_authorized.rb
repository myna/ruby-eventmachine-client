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

  describe "reset" do
    it "must reset variants to zero" do
      myna = Myna.authorize("test@example.com", "themostsecretpassword")

      expt = myna.create("reseto").get
      expt.must_be_kind_of Myna::AuthorizedExperiment

      expt.create_variant("Best variant evar").get.must_be_kind_of Response::Ok
      suggestion = expt.suggest().get
      expt.reward(suggestion.token, 1.0)

      info = expt.info().get
      info.variants[0].totalReward.must_equal 1.0
      info.variants[0].views.must_equal 1

      expt.reset().get.must_be_kind_of Response::Ok

      info = expt.info().get
      info.variants[0].totalReward.must_equal 0
      info.variants[0].views.must_equal 0

      expt.delete().get
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

      v1 = nil
      v2 = nil
      if info.variants[0].name == 'variant1'
        info.variants[1].name.must_equal 'variant2'
        v1 = info.variants[0]
        v2 = info.variants[1]
      else
        info.variants[0].name.must_equal 'variant2'
        info.variants[1].name.must_equal 'variant1'
        v1 = info.variants[1]
        v2 = info.variants[0]
      end

      # Check attributes are all present
      def check_attributes(variant)
        variant.views.must_be_kind_of Fixnum
        variant.totalReward.must_be_kind_of Float
        variant.upperConfidenceBound.must_be_kind_of Float
        variant.lowerConfidenceBound.must_be_kind_of Float
      end

      check_attributes(v1)
      check_attributes(v2)
    end
  end
end
