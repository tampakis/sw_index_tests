require 'spec_helper'
require 'rspec-solr'

describe "Author Search Request Handler" do
  
  it "Corporate author should be included in author search" do
    resp = solr_resp_doc_ids_only({'q'=>'Anambra State', 'qt'=>'search_author'})
    resp.should have_at_least(80).documents
    # other examples:  "Plateau State", tanganyika, gold coast
  end
  
  it "Thesis advisors (720 fields) should be included in author search" do
    resp = solr_resp_doc_ids_only({'q'=>'Zare', 'qt'=>'search_author'})
    resp.should have_at_least(100).documents
  end
  
  it "added authors (700 fields) should be included in author search" do
    resp = solr_resp_doc_ids_only({'q'=>'jane hannaway', 'qt'=>'search_author'})
    resp.should include("2503795")
    resp.should have_at_least(8).documents
  end
  
  it "unstemmed author names should precede stemmed variants" do
    pending "need regex match"
    resp = solr_resp_doc_ids_only({'q'=>'Zare', 'qt'=>'search_author', 'fl'=>'id,author_person_display', 'rows'=>'30'})
    resp.should_not include(":author_person_display" => "Zare").in_first(20).documents
    resp.should_not include(":author_person_display" => "Zaring, Wilson M.").in_first(20).documents
    resp.should_not include(":author_person_display" => "Stone, Grace Zaring, 1891-.").in_first(20).documents
  end
  
  it "non-existent author 'jill kerr conway' should get 0 results" do
    resp = solr_resp_doc_ids_only({'q'=>'jill kerr conway', 'qt'=>'search_author'})
    resp.should have(0).documents
  end
  
end