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
require 'response'

describe Response do

  describe "parse" do
    it "must parse an error" do
      txt = '{"typename":"mynaapierror","code":1411,"message":"Experiment cannot be found"}'
      ans = Response.parse(txt)

      ans.must_be_kind_of Response::ApiError
      ans.code.must_equal 1411
      ans.message.must_equal "Experiment cannot be found"
    end

    it "must parse ok" do
      ans = Response.parse('{"typename":"ok"}')
      
      ans.must_be_kind_of Response::Ok
    end

    it "must parse a suggestion" do
      txt = '{"typename":"suggestion","token":"871ec6f8-bea7-4a51-ba48-33bdfea9feb2","choice":"variant2"}'
      ans = Response.parse(txt)

      ans.must_be_kind_of Response::Suggestion
      ans.token.must_equal  '871ec6f8-bea7-4a51-ba48-33bdfea9feb2'
      ans.choice.must_equal 'variant2'
    end

    it "must parse a uuid" do
      ans = Response.parse('{"typename":"uuid","uuid":"f8d9eb79-3d8f-41b0-9044-605faddd959c"}')
      
      ans.must_be_kind_of Response::Uuid
      ans.uuid.must_equal 'f8d9eb79-3d8f-41b0-9044-605faddd959c'
    end

    it "must parse an experiment" do
      txt = '{"typename":"experiment",
              "name":"test",
              "uuid":"45923780-80ed-47c6-aa46-15e2ae7a0e8c",
              "accountId":"eb1fb383-4172-422a-b680-8031cf26a23e",
              "variants":[
                 {"typename":"variant",
                  "name":"variant1",
                  "views":36,
                  "totalReward":1.0,
                  "confidenceBound":0.252904521564191},
                 {"typename":"variant",
                  "name":"variant2",
                  "views":9672,
                  "totalReward":0.0,
                  "confidenceBound":0.015429423531830728}]}'
      ans = Response.parse(txt)

      ans.must_be_kind_of Response::Experiment
      ans.name.must_equal "test"
      ans.uuid.must_equal "45923780-80ed-47c6-aa46-15e2ae7a0e8c"
      ans.accountId.must_equal "eb1fb383-4172-422a-b680-8031cf26a23e"
      
      v0 = ans.variants[0]
      v1 = ans.variants[1]
      
      v0.name.must_equal "variant1"
      v0.views.must_equal 36
      v0.totalReward.must_equal 1.0
      v0.confidenceBound.must_equal 0.252904521564191

      v1.name.must_equal "variant2"
      v1.views.must_equal 9672
      v1.totalReward.must_equal 0.0
      v1.confidenceBound.must_equal 0.015429423531830728
    end
  end
end
