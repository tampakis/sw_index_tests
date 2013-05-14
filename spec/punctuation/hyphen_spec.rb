require 'spec_helper'

describe "hyphen in queries" do

  # hyphens between characters (no spaces) are to be treated as a phrase search for surrounding terms, 
  # so 'a-b' and '"a b"' are equivalent query strings
  shared_examples_for "hyphens without spaces" do | query, exp_ids, first_x |
    before(:all) do
      q_as_phrase = "\"#{query}\""
      q_as_phrase_no_hyphen = "\"#{query.sub('-', ' ')}\""
      q_split = query.split('-')
      if q_split.size == 2 
        term_before = q_split.first.split(' ').last
        start_of_query = q_split.first.split(term_before).first
        start_of_query.strip if start_of_query
        term_after = q_split.last.split(' ').first
        rest_of_query = q_split.last.split(term_after).last
        rest_of_query.strip if rest_of_query
        q_no_hyphen_phrase = "#{start_of_query} \"#{term_before} #{term_after}\" #{rest_of_query}" 
      end
      @resp = solr_resp_ids_from_query(query)
      @presp = solr_resp_ids_from_query(q_no_hyphen_phrase) 
      @tresp = solr_resp_doc_ids_only(title_search_args(query))
      @ptresp = solr_resp_doc_ids_only(title_search_args(q_no_hyphen_phrase))
      @resp_whole_phrase = solr_resp_ids_from_query(q_as_phrase)
      @resp_whole_phrase_no_hyphen = solr_resp_ids_from_query(q_as_phrase_no_hyphen)
      @tresp_whole_phrase = solr_resp_ids_from_query(title_search_args(q_as_phrase))
      @tresp_whole_phrase_no_hyphen = solr_resp_ids_from_query(title_search_args(q_as_phrase_no_hyphen))
    end
    it "should have great results for query" do
      @resp.should include(exp_ids).in_first(first_x).documents
      @presp.should include(exp_ids).in_first(first_x).documents
      @tresp.should include(exp_ids).in_first(first_x).documents
      @ptresp.should include(exp_ids).in_first(first_x).documents
      @resp_whole_phrase.should include(exp_ids).in_first(first_x).documents
      @resp_whole_phrase_no_hyphen.should include(exp_ids).in_first(first_x).documents
    end
    it "should treat hyphen as phrase search for surrounding terms in everything searches" do
      @resp.should have_the_same_number_of_documents_as(@presp)
    end
    it "should treat hyphen as phrase search for surrounding terms in title searches" do
      @tresp.should have_the_same_number_of_documents_as(@ptresp)
    end
    it "phrase search for entire query should get the same results with or without hyphen" do
      @resp_whole_phrase.should have_the_same_number_of_documents_as(@resp_whole_phrase_no_hyphen)
    end
    it "title phrase search for entire query should get the same results with or without hyphen" do
      @tresp_whole_phrase.should have_the_same_number_of_documents_as(@tresp_whole_phrase_no_hyphen)
    end
  end
  
  context "'neo-romantic'", :jira => 'VUF-798' do
    it_behaves_like "hyphens without spaces", "neo-romantic", ["7789846", "2095712", "7916667", "5627730", "1665493", "2775888", "1688481"], 12
  end

  context "'cat-dog'" do
    it_behaves_like "hyphens without spaces", "cat-dog", "6741004", 20
  end

  context "'1951-1960'" do
    it_behaves_like "hyphens without spaces", "1951-1960", "2916430", 20
  end
  
  it "'0256-1115' (ISSN)" do
    # not useful to search as title ...
    resp = solr_resp_ids_from_query('0256-1115')
    presp = solr_resp_ids_from_query('"0256 1115"')
    resp.should include("4108257").as_first
    presp.should include('4108257').as_first
    resp.should have_the_same_number_of_documents_as(presp)
  end

  context "'Deutsch-Sudwestafrikanische Zeitung'", :jira => 'VUF-803' do
    it_behaves_like "hyphens without spaces", "Deutsch-Sudwestafrikanische Zeitung", ["410366", "8230044"], 2
  end

  context "'red-rose chain'", :jira => 'SW-388' do
    it_behaves_like "hyphens without spaces", "red-rose chain", ["5335304", "8702148"], 3
  end
  context "'prisoner in a red-rose chain'", :jira => 'SW-388' do
    it_behaves_like "hyphens without spaces", "prisoner in a red-rose chain", "8702148", 1
  end
  
  context "'under the sea-wind'", :jira => 'VUF-966' do
    it_behaves_like "hyphens without spaces", "under the sea-wind", ["5621261", "545419", "2167813"], 3
  end
  
  context "'customer-driven academic library'", :jira => 'SW-388' do
    it_behaves_like "hyphens without spaces", "customer-driven academic library", "7778647", 1
  end
  
  context "'catalogue of high-energy accelerators'", :jira => 'VUF-846' do
    it_behaves_like "hyphens without spaces", "catalogue of high-energy accelerators", "1156871", 1
  end

  context "'Mid-term fiscal policy review'", :jira => 'SW-388' do
    it_behaves_like "hyphens without spaces", "Mid-term fiscal policy review", ["7204125", "5815422"], 3
  end
  
  context "'The third plan mid-term appraisal'" do
    it_behaves_like "hyphens without spaces", "The third plan mid-term appraisal", "2234698", 1
  end

  context "'Color-blindness; its dangers and its detection'", :jira => 'SW-94' do
    it_behaves_like "hyphens without spaces", "Color-blindness; its dangers and its detection", ["7329437", "2323785"], 2
  end
  context "'Color-blindness [print/digital]; its dangers and its detection'", :jira => 'SW-94' do
    # 2323785 is NOT present for the entire query as a phrase search;  it is present otherwise
    #   we don't include 245h in title_245_search, and 245h contains "[print/digital]"    
    it_behaves_like "hyphens without spaces", "Color-blindness [print/digital]; its dangers and its detection", ["7329437"], 2
  end

end