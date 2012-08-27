# -*- encoding : utf-8 -*-
require 'spec_helper'
require 'rspec-solr'

describe "Korean: Single Character Searches", :korean => true, :fixme => true do
  
  it "title  창 (window) should get results" do
    resp = solr_response({'q'=>'창', 'fl'=>'id,vern_title_245a_display', 'rows'=>20, 'qt'=>'search_title', 'facet'=>false}) 
    resp.should include('vern_title_245a_display'=>'창').in_first(14).documents 
    resp.should include("7875201")
    resp.should have_at_least(299).documents # 14 in prod, 299 title in soc
  end
  
  it "title  꿈 (dream) should get results" do
    resp = solr_response({'q'=>'꿈', 'fl'=>'id,vern_title_245a_display', 'qt'=>'search_title', 'facet'=>false}) 
    resp.should include('vern_title_245a_display'=>'꿈').in_first(7).documents 
    resp.should include("7875201") 
    resp.should have_at_least(115).documents # 87 in prod, 115 title in soc
  end
  
end