require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'test_helper'))

module MingleEvents
  module Processors
    class CategoryFilterTest < Test::Unit::TestCase
        
      def test_match_against_one_category
        filter = CategoryFilter.new([Feed::Category::CARD])
        assert filter.match?(stub_event(1, [Feed::Category::CARD, Feed::Category::COMMENT_ADDITION]))
        assert filter.match?(stub_event(1, [Feed::Category::CARD]))
        assert !filter.match?(stub_event(1, [Feed::Category::COMMENT_ADDITION]))
        assert !filter.match?(stub_event(1, [Feed::Category::REVISION_COMMIT, Feed::Category::COMMENT_ADDITION]))
      end
      
      def test_match_against_multiple_categories
        filter = CategoryFilter.new([Feed::Category::CARD, Feed::Category::COMMENT_ADDITION])
        assert filter.match?(stub_event(1, [Feed::Category::CARD, Feed::Category::COMMENT_ADDITION]))
        assert !filter.match?(stub_event(1, [Feed::Category::CARD]))
        assert !filter.match?(stub_event(1, [Feed::Category::REVISION_COMMIT, Feed::Category::COMMENT_ADDITION]))
      end
      
      private 
  
      def stub_event(id, categories)
        OpenStruct.new(:entry_id => id, :categories => categories)
      end

    end
  end
end
