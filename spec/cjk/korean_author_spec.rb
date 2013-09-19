# -*- encoding : utf-8 -*-
require 'spec_helper'

describe "Korean spacing", :korean => true do
  
  context "author: Ŭn, Hŭi-gyŏng", :jira => 'VUF-2729' do
    #  "top 15 results are all relevant for searches both with and without whitespace between author’s last and first name."
    relevant = ['9628681',
                '8814719',
                '7874461',
                '8299426',
                '9097174',
                '8532805',
                '8823369',
                '7874535',
                '7890077',
                '7868363',
                '7849970',
                '8827330',
                '7880024',
                '7841550',
                '6972331',
              ]
    irrelevant = ['10150829', # has one contributor with last name, another contributor with first name
                  '9588786',  # has 3 chars jumbled in 710:  경희 대학교. 밝은 사회 연구소
                  ]
    shared_examples_for "good author results for 은희경" do | query |
      it_behaves_like 'good results for query', 'author', query, 15, 30, relevant, 20
      it_behaves_like 'does not find irrelevant results', 'author', query, irrelevant
    end
    context "은희경 (no spaces)" do
      it_behaves_like "good author results for 은희경", '은희경'
    end
    context "은 희경 (spaces:  은: last name  희경:first name)" do
      it_behaves_like "good author results for 은희경", '은희경'
    end
  end # author: Ŭn, Hŭi-gyŏng  VUF-2729

  context "author: Kang, In-ch'ŏl", :jira => 'VUF-2721' do
    chars_together_in_100 = ['6914120', '6724932']
    chars_w_space_in_100_space = ['9954769',  # as  강 인철
                              '9927817',
                              '8504300',
                              '9957716',
                              '7692263' ]
    shared_examples_for "good author results for 강인철" do | query |
      it_behaves_like 'good results for query', 'author', query, 7, 10, chars_together_in_100 + chars_w_space_in_100_space, 7
    end
    shared_examples_for "good everything results for 강인철" do | query |
      it_behaves_like 'good author results for 강인철', query
      in_245c = '9688452' # 245c has 편집 강 인철].
      in_245c_and_700 = '7850201'  # 245c has [著者 강 인철
      it_behaves_like 'best matches first', 'everything', query, [in_245c, in_245c_and_700], 10
      chars_out_of_order = '9696801' #  철강인  in 245a, 246a
      it_behaves_like 'does not find irrelevant results', 'author', query, chars_out_of_order
    end
    context "author search" do
      context "강인철 (no spaces)" do
        it_behaves_like "good author results for 강인철", '강인철'
      end
      context "강 인철 (spaces:  강: last name  인철:first name)" do
        it_behaves_like "good author results for 강인철", '강 인철'
      end
    end
    context "everything search" do
      context "강인철 (no spaces)" do
        it_behaves_like "good everything results for 강인철", '강인철'
      end
      context "강 인철 (spaces:  강: last name  인철:first name)" do
        it_behaves_like "good everything results for 강인철", '강 인철'
      end
    end
  end # author   Kang, In-ch'ŏl  VUF-2721

end