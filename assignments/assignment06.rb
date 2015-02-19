# Tim Hall Assignment 6


# ========================================================================================
# Assignment 5
# ========================================================================================

# ========================================================================================
#  Problem 1 - PriorityQueue

# implement a PriorityQueue, validate using MiniTest unit tests


module Assignment06

  class PriorityQueue
    attr_accessor :nodes

    class Node
      attr_accessor :item, :priority, :link
      def initialize (item, priority, link)
        @item = item
        @priority = priority
        @link = link
      end
    end

    def initialize
      @nodes = nil
    end

    def enqueue(item, priority=:medium)
      new_node = Node.new item, priority, nil           # new node does not point to next node yet. need to figure out where to insert it...
      if empty?                               
        @nodes = new_node
      else
        node = @nodes                           
        if new_node.priority == :high                 # if priority of new node is high, insert it after the last high node.
          while node.link
            if node.link.priority == :medium || node.link.priority == :low 
              new_node.link = node.link
              node.link = new_node
              break
            else
              node = node.link
            end
          end
        elsif new_node.priority == :medium      # if priority of new node is medium, insert it after the last medium node.
          while node.link
            if node.link.priority == :low 
              new_node.link = node.link
              node.link = new_node
              break
            else
              node = node.link
            end
          end  
        elsif new_node.priority == :low         # if priority of new node is low, make it the last node in the list.
          while node.link
            node = node.link
          end
          node.link = new_node
        end
      end
      self
    end

    def dequeue
      node = @nodes
      @nodes = node.nil? ? nil : node.link
      node.nil? ? nil : node.item
    end

    def empty?
      @nodes.nil?
    end

    def peek
      @nodes.nil? ? nil : @nodes.item
    end

    def length
      return 0  if empty?

      node = @nodes
      count = 1
      while node.link
        count += 1
        node = node.link
      end
      count
    end

  end
end
# expected results:
# pq = PriorityQueue.new
# pq.empty?      #=> true

# pq.enqueue "first"
# pq.empty?      #=> false

# pq.enqueue "top", :high
# pq.enqueue "last", :low
# pq.enqueue "second"
# pq.enqueue "another top", :high

# pq.length     #=> 5

# pq.dequeue    #=> "top"
# pq.dequeue    #=> "another top"
# pq.dequeue    #=> "first"
# pq.dequeue    #=> "second"
# pq.dequeue    #=> "last"


# ========================================================================================
require 'minitest/autorun'

class TestPriorityQueue < Minitest::Test

  def test_PriorityQueue
    pq = Assignment06::PriorityQueue.new
    refute_nil pq
    assert_empty pq           #=> true
    assert_equal 0, pq.length
    assert_equal pq.empty?, true #=> both should be true

    assert_equal pq, pq.enqueue("first")
    refute_empty pq            #=> true
    assert_equal 1, pq.length
    assert_equal "first", pq.peek

    assert_equal pq, pq.enqueue("top", :high)
    refute_empty pq            #=> true
    assert_equal 2, pq.length
    assert_equal "top", pq.peek

    assert_equal pq, pq.enqueue("last", :low)
    refute_empty pq            #=> true
    assert_equal 3, pq.length
    assert_equal "top", pq.peek

    assert_equal pq, pq.enqueue("second")
    refute_empty pq            #=> true
    assert_equal 4, pq.length
    assert_equal "top", pq.peek

    assert_equal pq, pq.enqueue("another top", :high)
    refute_empty pq            #=> true
    assert_equal 5, pq.length
    assert_equal "top", pq.peek

    assert_equal "top", pq.dequeue           #=> "top"
    refute_empty pq            #=> true
    assert_equal 4, pq.length
    assert_equal "another top", pq.peek

    assert_equal "another top", pq.dequeue           #=> "another top"
    refute_empty pq            #=> true
    assert_equal 3, pq.length
    assert_equal "first", pq.peek

    assert_equal "first", pq.dequeue           #=> "first"
    refute_empty pq            #=> true
    assert_equal 2, pq.length
    assert_equal "second", pq.peek

    assert_equal "second", pq.dequeue           #=> "second"
    refute_empty pq            #=> true
    assert_equal 1, pq.length
    assert_equal "last", pq.peek

    assert_equal "last", pq.dequeue           #=> "last"
    assert_empty pq            #=> true
    assert_equal 0, pq.length

    assert_nil pq.dequeue           #=> nil
  end
  
end


# ========================================================================================
#  Problem 2 - Recipe to DSL

# render a Recipe object to Recipe DSL

class Recipe
  attr_accessor :steps, :ingredients, :name, :category, :prep_time, :rating
  def initialize(name)
    @name = name
  end
  
  def render_dsl
    def recipe(text, &block)
      @recipe << "recipe \"#{text}\" do\n"
      if block_given?
        content = yield
        if content
          @recipe << content.to_s
        end
      end
      text << "end\n"
    end

    def category(text)
      @recipe << "category \"#{text}\"\n"
    end

    def prep_time(text)
      @recipe << "prep_time \"#{text}\"\n"
    end

    def rating(text)
      @recipe << "rating \"#{text}\"\n"
    end

    def list(list_name, items=[])
      @recipe << "#{list_name} do\n"
        items.each{|item| @recipe << "x \"#{item}\"\n"}
      @recipe << "end\n"
    end

    alias method_missing list     # any unknown method is treated like list method. This includes "ingredients" and "steps"
    
  end
end

class RecipeBuilder
  def recipe(name, &block)
    @recipe = Recipe.new(name)
    self.instance_eval &block
    @recipe
  end
  
  def category(value)
    @recipe.category = value
  end
  
  def prep_time(value)
    @recipe.prep_time = value
  end
  
  def rating(value)
    @recipe.rating = value
  end
  
  def ingredients(&block)
    @recipe.ingredients = []
    @items = @recipe.ingredients
    self.instance_eval &block
  end
  
  def steps(&block)
    @recipe.steps = []
    @items = @recipe.steps
    self.instance_eval &block
  end
  
  def x(item)
    @items << item
  end
end

def recipe(name, &block)
  rb = RecipeBuilder.new
  rb.recipe(name, &block)
end
