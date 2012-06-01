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

  after do
  end

  describe "suggest" do
    it "must return a suggestion for a valid experiment" do
      expt = Myna.experiment('45923780-80ed-47c6-aa46-15e2ae7a0e8c')
      ans = expt.suggest
      ans.get.must_be_kind_of Response::Suggestion
    end

    it "must return an error for an invalid experiment" do
      expt = Myna.experiment('bogus')
      ans = expt.suggest
      ans.get.must_be_kind_of Response::ApiError
    end
  end

  describe "reward" do
    it "must succeed when given correct token and amount" do
      expt = Myna.experiment('45923780-80ed-47c6-aa46-15e2ae7a0e8c')
      suggestion = expt.suggest.get

      ans = expt.reward(suggestion.token, 0.5)
      ans.get
      ans.get.must_be_kind_of Response::Ok
    end
  end

end
