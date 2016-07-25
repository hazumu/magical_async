require "spec_helper"
require "net/http"

describe "MagicalAsync.parallel" do

  it "should return hash with corrext keys" do
    MagicalAsync.parallel({
       first: -> (callback) {
        callback.call 'first'
       },
       second: -> (callback) {
        callback.call 'second'
       },
       third: -> (callback) {
        callback.call 'third'
       },
     }, -> (res) { 
         expect(res).to include(first: 'first', second: 'second', third: 'third')
       })
  end

end
