require 'spec_helper'

describe "boolean operators" do
  
  # TODO: more better tests for lowercase and?
  # TODO: what about lowercase not?
  # TODO: what about OR/or ?

  context "default operator:  AND" do

    context "everything search" do
      it "more search terms should get fewer results" do
        resp = solr_resp_ids_from_query 'horn'
        resp.should have_more_documents_than(solr_resp_ids_from_query 'french horn')
      end
      it "loggerhead turtles should not have Shakespeare in facets" do
        resp = solr_response({'q'=>'loggerhead turtles', 'fl' => 'id'})
        # Shakespeare was in the facets when default was "OR"
        resp.should_not have_facet_field("author_person_facet").with_value("Shakespeare, William, 1564-1616")
        resp = solr_response({'q'=>'turtles', 'fl' => 'id'})
        resp.should have_facet_field("author_person_facet").with_value("Shakespeare, William, 1564-1616")
      end
    end

    context "author search" do
      it "more search terms should get fewer results" do
        resp = solr_resp_doc_ids_only(author_search_args('michaels'))
        resp.should have_more_documents_than(solr_resp_doc_ids_only(author_search_args('leonard michaels')))
      end
    end
    
    context "title search" do
      it "more search terms should get fewer results" do
        resp = solr_resp_doc_ids_only(title_search_args('turtles'))
        resp.should have_more_documents_than(solr_resp_doc_ids_only(title_search_args('sea turtles')))
      end
    end
    
    it "across MARC fields (author and title)" do
      resp = solr_resp_ids_from_query 'gulko sea turtles'
      resp.should have(1).document
      resp.should include("5958831")
      resp = solr_resp_ids_from_query 'eckert sea turtles'
      resp.should have(1).document
      resp.should include("5958831")
    end
    
    context "5 terms with AND" do
      before(:all) do
        @resp = solr_resp_ids_from_query 'Catholic thought AND papal jewry policy'
      end
      it "should include doc 1711043" do
        @resp.should have(1).document
        @resp.should include("1711043")
      end
      it "should get the same results as lowercase 'and'" do
        @resp.should have_the_same_number_of_documents_as(solr_resp_ids_from_query 'Catholic thought and papal jewry policy')
      end
    end
    
    it "lower case 'and' behaves like upper case AND", :jira => 'VUF-626' do
      resp = solr_resp_ids_from_query 'South Africa, Shakespeare AND post-colonial culture'
      resp.should include(["8505958", "4745861", "7837826", "7756621"])
      resp2 = solr_resp_ids_from_query 'South Africa, Shakespeare and post-colonial culture'
      resp2.should include(["8505958", "4745861", "7837826", "7756621"])
      resp.should have_the_same_number_of_documents_as(resp2)
    end
    
  end # context AND
  
  context "NOT operator" do

    shared_examples_for "NOT negates following term" do | query, exp_ids, un_exp_ids, first_n |
      before(:all) do
        @resp = solr_resp_ids_from_query query
      end
      it "should have expected results" do
        @resp.should include(exp_ids).in_first(first_n).documents
      end
      it "should not have unexpected results" do
        @resp.should_not include(un_exp_ids)
      end
      it "query that includes term should match unexpected ids" do 
        # or we don't have good unexpected ids for the test
        resp_w_term = solr_resp_ids_from_query query.sub(' NOT ', ' ')
        resp_w_term.should include(un_exp_ids)
      end
      it "should have fewer results than query without NOT clause" do
        @resp.should have_fewer_documents_than(solr_resp_ids_from_query query.sub(/ NOT \S+ ?/, ' '))
      end
      it "hyphen with space before but not after (' -a') should be equivalent to NOT" do
        @resp.should have_the_same_number_of_documents_as(solr_resp_ids_from_query query.sub(' NOT ', ' -'))
      end
    end # shared examples for NOT in query
    
    #  per Google Analytics mid-April - mid- May 2013
    context "actual user queries" do
      context "space exploration NOT nasa" do
        it_behaves_like "NOT negates following term", 'space exploration NOT nasa', "4146206", "2678639", 5
        it "has an appropriate number of results" do
          resp = solr_resp_ids_from_query 'space exploration NOT nasa'
          resp.should have_at_least(6300).documents
          resp.should have_at_most(7250).documents  # 2013-05-21  space exploration: 7896 results
        end
      end
    end
    
    context "wb4 NOT shakespeare" do
      it_behaves_like "NOT negates following term", 'wb4 NOT shakespeare', "2228164", "1989093", 20
      it "has an appropriate number of results" do
        resp = solr_resp_ids_from_query 'wb4 NOT shakespeare'
        resp.should have_at_least(7000).documents
      end
      before(:all) do
        @resp = solr_resp_ids_from_query 'wb4 NOT shakespeare'
      end
    end
    
    context "twain NOT sawyer" do
      before(:all) do
        @resp = solr_resp_ids_from_query 'twain NOT sawyer'
      end
      it "should have fewer results than query 'twain'" do
        @resp.should have_documents
        @resp.should have_fewer_documents_than(solr_resp_ids_from_query 'twain')
      end
      it "should be equivalent to twain -sawyer" do
        @resp.should have_the_same_number_of_documents_as(solr_resp_ids_from_query 'twain -sawyer')
      end
    end

    context "query with NOT applied to phrase:  mark twain NOT 'tom sawyer'" do
      before(:all) do
        @resp = solr_resp_ids_from_query 'mark twain NOT "tom sawyer"'
      end
      
      it "should have no results with 'tom sawyer' as a phrase" do
        resp = solr_response({'q'=>'mark twain NOT "tom sawyer"', 'fl'=>'id,title_245a_display', 'facet'=>false}) 
        @resp.should have_at_least(1400).documents
        resp.should_not include("title_245a_display" => /tom sawyer/i).in_each_of_first(20).documents
      end
      it "should be equivalent to mark twain -'tom sawyer'" do
        @resp =  have_the_same_number_of_documents_as(solr_resp_ids_from_query 'mark twain -"tom sawyer"')
      end
      it "should get more results than 'mark twain 'tom sawyer''" do
        @resp.should have_more_results_than(solr_resp_ids_from_query 'mark twain "tom sawyer"')
      end
      it "should get more results than 'mark twain tom sawyer'" do
        @resp.should have_more_results_than(solr_resp_ids_from_query 'mark twain tom sawyer')
      end

      it "should work with parens", :jira => 'VUF-379', :fixme => true, :edismax => true do
        resp = solr_resp_ids_from_query 'mark twain NOT (tom sawyer)'
        resp.should have_at_least(1400).documents
      end
      it "with parens inside quote" do
        resp = solr_resp_ids_from_query 'mark twain NOT "(tom sawyer)"' # 0 documents
        resp.should have_at_least(1400).documents
        resp.should have_the_same_number_of_documents_as(@resp)
      end
      it "with parens outside quote", :fixme => true, :edismax => true do
        resp = solr_resp_ids_from_query 'mark twain NOT ("tom sawyer")' # 0 documents
        resp.should have_at_least(1400).documents
        resp.should have_the_same_number_of_documents_as(@resp)
      end
      it "with unmatched paren inside quotes" do
        @resp.should have_the_same_number_of_documents_as(solr_resp_ids_from_query 'mark twain NOT "(tom sawyer"')
        @resp.should have_the_same_number_of_documents_as(solr_resp_ids_from_query 'mark twain NOT "tom( sawyer"')
        @resp.should have_the_same_number_of_documents_as(solr_resp_ids_from_query 'mark twain NOT "tom (sawyer"')
        @resp.should have_the_same_number_of_documents_as(solr_resp_ids_from_query 'mark twain NOT "tom sawyer("')
        @resp.should have_the_same_number_of_documents_as(solr_resp_ids_from_query 'mark twain NOT ")tom sawyer"')
        @resp.should have_the_same_number_of_documents_as(solr_resp_ids_from_query 'mark twain NOT "tom) sawyer"')
        @resp.should have_the_same_number_of_documents_as(solr_resp_ids_from_query 'mark twain NOT "tom )sawyer"')
        @resp.should have_the_same_number_of_documents_as(solr_resp_ids_from_query 'mark twain NOT "tom sawyer)"')
      end
      it "with unmatched parent outside quote", :fixme => true do
        @resp.should have_the_same_number_of_documents_as(solr_resp_ids_from_query 'mark twain NOT ("tom sawyer"')
        @resp.should have_the_same_number_of_documents_as(solr_resp_ids_from_query 'mark twain NOT "tom sawyer"(')
        @resp.should have_the_same_number_of_documents_as(solr_resp_ids_from_query 'mark twain NOT )"tom sawyer"')
        @resp.should have_the_same_number_of_documents_as(solr_resp_ids_from_query 'mark twain NOT "tom sawyer")')
      end
      it "with unmatched quote", :jira => 'VUF-379', :fixme => true, :edismax => true do
        resp = solr_resp_ids_from_query 'mark twain NOT "tom sawyer' # 0 documents
        resp = solr_resp_ids_from_query 'mark twain NOT tom sawyer' # 0 documents
        resp.should have_at_least(1400).documents
      end
    end
  end # context NOT
  
end