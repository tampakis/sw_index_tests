# -*- encoding : utf-8 -*-
require 'spec_helper'

describe "Chinese Old (舊) Fiction (小說)", :chinese => true, :fixme => true, :vetted => 'vitus' do
  # old (simp)  旧
  # old (trad)  舊
  # fiction (simp)  小说
  # fiction (trad)  小說

  shared_examples_for "great search results for 舊小說" do
    it "gets the traditional char matches" do
      # the first 4 lines are redundant, but split out for ease of diagnostics
      resp.should include(["9262744", "6797638", "6695967"]) # in 245a
      resp.should include("6696790") # in 245a but not adjacent
      resp.should include("6695904") # three characters in 245a, but in a different order 
      resp.should include("6699444") # in 245a and b
      resp.should include(["9262744", "6797638", "6695967"]).before(["6696790", "6695904", "6699444"])
      resp.should include("6695904").before("6699444")
    end
    it "gets the simplified char matches" do
      resp.should include("8834455") # all three chars in 245a
      resp.should include("4192734")  # diff word order in 245a  小说旧
      resp.should include("8834455").before("4192734")
    end
    it "ranks highest the documents with adjacent words in 245a" do
      resp.should include("9262744").in_first(5).results # old fiction: 245a
      resp.should include("6797638").in_first(5).results # old fiction: 245a
      resp.should include("6695967").in_first(5).results # old fiction: 245a
      resp.should include("8834455").in_first(5).results # translated to simplified, all three in 245a
    end
    it "ranks very high the documents with both words in 245a but not adjacent" do
      resp.should include(["4192734"]).in_first(6).results #  # diff word order in 245a  小说旧
    end
    it "ranks high the documents with one word in 245a and the other in 245b" do
      resp.should include("6695904").in_first(12).results # fiction 245a; old 245a
      resp.should include("6699444").in_first(12).results # old 245a; fiction 245b
      resp.should include("6696790").in_first(12).results # old 245a; fiction 245a
      resp.should include("7198256").in_first(12).results # old 245b; fiction: 245a  (Korean also in record)
      resp.should include("6793760").in_first(12).results # old (simplified) 245a; fiction 245b
    end
    it "includes other relevant results" do
      resp.should include("6288832") # old 505t; fiction 505t x2
      resp.should include("7699186") # old (simp) in 245a, fiction (simp) in 490 and 830
      resp.should include("6204747") # old 245a; fiction 490a; 830a
      resp.should include("6698466") # old 245a; fiction 490a, 830a
    end
  end # shared examples  great search results for 舊小說

  context "title search" do
    shared_examples "great title search results for 舊小說" do
      it "gets a reasonable number of results" do
        resp.should have_at_least(8).documents
        resp.should have_at_most(15).documents
      end
    end

    context "traditional  舊小說 no spaces" do
      before(:all) do
        @resp = solr_resp_doc_ids_only(title_search_args('舊小說').merge({'rows'=>'25'}))
      end
#      it_behaves_like "great search results for 舊小說", @resp
      it_behaves_like "great search results for 舊小說" do
        let (:resp) { @resp }
      end
#      it_behaves_like "great title search results for 舊小說", @resp
      it_behaves_like "great title search results for 舊小說" do
        let (:resp) { @resp }
      end
    end
    context "traditional  舊 小說  with space" do
      before(:all) do
        @resp = solr_resp_doc_ids_only(title_search_args('舊 小說').merge({'rows'=>'25'}))
      end
#      it_behaves_like "great search results for 舊小說", @resp
#      it_behaves_like "great title search results for 舊小說", @resp
      it_behaves_like "great search results for 舊小說" do
        let (:resp) { @resp }
      end

      context "traditional  舊 小說  with space" do
        before(:all) do
          @resp = solr_resp_doc_ids_only(title_search_args('舊 小說').merge({'rows'=>'25'}))
        end
        it_behaves_like "great search results for 舊小說" do
          let (:resp) { @resp }
        end
        it_behaves_like "great title search results for 舊小說" do
          let (:resp) { @resp }
        end
      end
    end
    context "simplified  旧小说 no spaces" do
      before(:all) do
        @resp = solr_resp_doc_ids_only(title_search_args('旧小说').merge({'rows'=>'25'}))
      end
#      it_behaves_like "great search results for 舊小說", @resp
#      it_behaves_like "great title search results for 舊小說", @resp
      it_behaves_like "great search results for 舊小說" do
        let (:resp) { @resp }
      end
      it_behaves_like "great title search results for 舊小說" do
        let (:resp) { @resp }
      end
    end
    context "simplified  旧 小说  with space" do
      before(:all) do
        @resp = solr_resp_doc_ids_only(title_search_args('旧 小说').merge({'rows'=>'25'}))
      end
#      it_behaves_like "great search results for 舊小說", solr_resp_doc_ids_only(title_search_args('旧 小说').merge({'rows'=>'25'}))
#      it_behaves_like "great title search results for 舊小說", solr_resp_doc_ids_only(title_search_args('旧 小说').merge({'rows'=>'25'}))
      it_behaves_like "great search results for 舊小說" do
        let (:resp) { @resp }
      end
      it_behaves_like "great title search results for 舊小說" do
        let (:resp) { @resp }
      end
    end
  end # context title search

  context "everything search" do
    shared_examples "great everything search results for 舊小說" do
      it "gets a reasonable number of results" do
        resp.should have_at_least(20).documents
        resp.should have_at_most(40).documents
      end
    end

    context "traditional  舊小說 no spaces" do
      before(:all) do
        @resp = solr_resp_doc_ids_only({'q'=>'舊小說', 'rows'=>'25'})
      end
#      it_behaves_like "great search results for 舊小說", solr_resp_doc_ids_only({'q'=>'舊小說', 'rows'=>'25'})
#      it_behaves_like "great everything search results for 舊小說", solr_resp_doc_ids_only({'q'=>'舊小說', 'rows'=>'25'})
      it_behaves_like "great search results for 舊小說" do
        let (:resp) { @resp }
      end
      it_behaves_like "great everything search results for 舊小說" do
        let (:resp) { @resp }
      end
    end
    context "traditional  舊 小說  with space" do
      before(:all) do
        @resp = solr_resp_doc_ids_only({'q'=>'舊 小說', 'rows'=>'25'})
      end
#      it_behaves_like "great search results for 舊小說", solr_resp_doc_ids_only({'q'=>'舊 小說', 'rows'=>'25'})
#      it_behaves_like "great everything search results for 舊小說", solr_resp_doc_ids_only({'q'=>'舊 小說', 'rows'=>'25'})
      it_behaves_like "great search results for 舊小說" do
        let (:resp) { @resp }
      end
      it_behaves_like "great search results for 舊小說" do
        let (:resp) { @resp }
      end
      it_behaves_like "great title search results for 舊小說" do
        let (:resp) { @resp }
      end
    end
    context "simplified  旧 小说  with space" do
      before(:all) do
        @resp = solr_resp_doc_ids_only(title_search_args('旧 小说').merge({'rows'=>'25'}))
      end
      it_behaves_like "great search results for 舊小說" do
        let (:resp) { @resp }
      end
      it_behaves_like "great title search results for 舊小說" do
        let (:resp) { @resp }
      end
    end
    context "traditional  舊 小說  with space" do
      before(:all) do
        @resp = solr_resp_doc_ids_only({'q'=>'舊 小說', 'rows'=>'25'})
      end
      it_behaves_like "great search results for 舊小說" do
        let (:resp) { @resp }
      end
      it_behaves_like "great everything search results for 舊小說" do
        let (:resp) { @resp }
      end
    end
    context "simplified  旧小说 no spaces" do
      before(:all) do
        @resp = solr_resp_doc_ids_only({'q'=>'旧小说', 'rows'=>'25'})
      end
#      it_behaves_like "great search results for 舊小說", solr_resp_doc_ids_only({'q'=>'旧小说', 'rows'=>'25'})
#      it_behaves_like "great everything search results for 舊小說", solr_resp_doc_ids_only({'q'=>'旧小说', 'rows'=>'25'})
      it_behaves_like "great search results for 舊小說" do
        let (:resp) { @resp }
      end
      it_behaves_like "great everything search results for 舊小說" do
        let (:resp) { @resp }
      end
    end
    context "simplified  旧 小说  with space" do
      before(:all) do
        @resp = solr_resp_doc_ids_only({'q'=>'旧 小说', 'rows'=>'25'})
      end
#      it_behaves_like "great search results for 舊小說", solr_resp_doc_ids_only({'q'=>'旧 小说', 'rows'=>'25'})
#      it_behaves_like "great everything search results for 舊小說", solr_resp_doc_ids_only({'q'=>'旧 小说', 'rows'=>'25'})
      it_behaves_like "great search results for 舊小說" do
        let (:resp) { @resp }
      end
      it_behaves_like "great everything search results for 舊小說" do
        let (:resp) { @resp }
      end
    end
  end # context everything search

end