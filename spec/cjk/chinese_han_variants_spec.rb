# -*- encoding : utf-8 -*-
require 'spec_helper'

describe "Chinese Han variants", :chinese => true, :fixme => true do

  context "Guangxu (pinyin input method vs our data)", :jira => ['VUF-2757', 'VUF-2751'] do
    # The Unicode code point of the "with dot" version (緖) is U+7DD6. And the code point for the "without dot" version (緒) is U+7DD2
    # In the Unicode standard, it is the "without dot" version (U+7DD2) that is linked to the simplified form (U+7EEA). The "with dot" version is not. 
    # We have more records with the "with dot" version than the "without dot" version. 
    it_behaves_like "both scripts get expected result size", 'everything', 'with dot', '光緖', 'without dot', '光緒', 5100, 5300
    it_behaves_like "both scripts get expected result size", 'everything', 'traditional (with dot)', '光緖', 'simplified', '光绪', 5100, 5300
    it_behaves_like "both scripts get expected result size", 'everything', 'without dot', '光緒', 'simplified', '光绪', 5100, 5300
    context "with dot U+7DD6  緖" do
      it_behaves_like "expected result size", 'everything', '光緖', 5100, 5300
    end
    context "without dot U+7DD2 緒" do
      it_behaves_like "expected result size", 'everything', '光緒', 5100, 5300
    end
    context "simplified U+7EEA 绪" do
      it_behaves_like "expected result size", 'everything', '光绪', 5100, 5300
    end
  end
  
  context "history research" do
    # the 3rd character
    #  历史硏究   硏  U+784F   in the records   6433575, 9336336
    #  历史研究   研  U+7814   simp
    #  歷史研究   研  U+7814  (also) trad
    shared_examples_for "great matches for history research" do | query_type, query |
      it_behaves_like "best matches first", query_type, query, ['6433575', '9336336'], 2
      it_behaves_like "matches in vern short titles first", query_type, query, /^歷史硏究$/, 2
    end
    context "no spaces" do
      it_behaves_like "both scripts get expected result size", 'title', 'traditional', '歷史研究', 'simplified', '历史研究', 562, 900
      it_behaves_like "great matches for history research", 'title', '歷史研究'
      it_behaves_like "great matches for history research", 'title', '历史研究'
    end
    context "with space" do
      it_behaves_like "both scripts get expected result size", 'title', 'traditional', '歷史 研究', 'simplified', '历史 研究', 1000, 1100
      it_behaves_like "great matches for history research", 'title', '歷史 研究'
      it_behaves_like "great matches for history research", 'title', '历史 研究'
    end
    context "as phrase" do
      it_behaves_like "both scripts get expected result size", 'title', 'traditional', '"歷史研究"', 'simplified', '"历史研究"', 155, 175
      it_behaves_like "great matches for history research", 'title', '"歷史研究"'
      it_behaves_like "great matches for history research", 'title', '"历史研究"'
    end
  end
  
  context "International Politics Quarterly", :jira => 'VUF-2691' do
    # the fifth character is different:  the traditional character is not xlated to the simple one
    # 硏 U+784F
    # 研 U+7814  (simp, and in record 7106961)
    # 硏 U+784F  (trad?)
    it_behaves_like "both scripts get expected result size", 'title', 'traditional', '國際政治硏究', 'simplified', '国际政治研究', 24, 40
    it_behaves_like "best matches first", 'title', '國際政治硏究', '7106961', 1
    it_behaves_like "best matches first", 'title', '国际政治研究', '7106961', 1
  end

  it "囯 vs  国" do
    # FIXME:  I expect this is a bad test
    resp = solr_resp_doc_ids_only({'q'=>'民囯时期社会调查丛编'}) # A (囯) is second char  # 1 in prod: 8593449, 2 in soc as of 2012-11
    resp.should have_at_least(3).documents
    resp.should include(["8593449", "6553207"])
    resp.should include("8940619")  # has title 民国时期社会调查丛编 - B (国) is second char  # 1 in prod: 8940619, 1 in soc as of 2012-11
  end

  #  敎 vs  教
  #  戦 vs  戰
  #  户 vs  戸

end