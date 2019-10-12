require "test_helper"
require 'date'
require 'set'

describe Taskit::Task do
  describe "when created" do
    it "validates priority is a single letter in A-Z" do
      _(-> { Taskit::Task.new("test", priority: "q") }).must_raise Taskit::InvalidPriorityError
      _(-> { Taskit::Task.new("test", priority: 1) }).must_raise Taskit::InvalidPriorityError
      _(-> { Taskit::Task.new("test", priority: 'AB') }).must_raise Taskit::InvalidPriorityError
    end
    it "requires description argument to be non-nil" do
      _(-> { Taskit::Task.new(nil) }).must_raise ArgumentError
    end
    it "extracts lower-cased contexts from description" do
      t = Taskit::Task.new("Schedule Goodwill pickup @Goodwill @phone")
      _(t.contexts).must_equal Set["goodwill", "phone"]
    end
    it "extracts lower-cased projects from description" do
      t = Taskit::Task.new("Call Mom +Family +PeaceLoveAndHappiness")
      _(t.projects).must_equal Set["family", "peaceloveandhappiness"]
    end
    it "distinguishes projects and contexts correctly" do
      t = Taskit::Task.new("Email SoAndSo at soandso@example.com")
      _(t.contexts).must_be_empty

      t = Taskit::Task.new("Learn how to add 2+2")
      _(t.projects).must_be_empty
    end
  end

  describe "when converted to a string" do
    it "must include task description" do
      t = Taskit::Task.new("get groceries")
      _(t.to_s).must_equal "get groceries"
    end

    it "must include creation date, if specified" do
      created = Date.new(2019, 10, 12)
      t = Taskit::Task.new("get groceries", created: created)
      _(t.to_s).must_equal "2019-10-12 get groceries"
    end

    it "must include priority at the beginning" do
      t = Taskit::Task.new("get groceries", priority: "A")
      _(t.to_s).must_equal "(A) get groceries"
    end

    it "prepends priority before creation date" do
      t = Taskit::Task.new("get groceries", created: Date.new(2019, 10, 12), priority: "A")
      _(t.to_s).must_equal "(A) 2019-10-12 get groceries"
    end

    it "prepends x and completion date for when task is complete" do
      t = Taskit::Task.new("get groceries")
      t.complete(Date.new(2019, 10, 12))
      _(t.to_s).must_equal "x 2019-10-12 get groceries"
    end

    it "prepends x and completion date before creation date" do
      t = Taskit::Task.new("get groceries", created: Date.new(2019, 10, 10))
      t.complete(Date.new(2019, 10, 12))
      _(t.to_s).must_equal "x 2019-10-12 2019-10-10 get groceries"
    end
  end

  describe "when completed" do
    it "verifies that completion date is non-nil" do
      t = Taskit::Task.new("get groceries")
      _(-> { t.complete(nil) }).must_raise ArgumentError
    end
    it "marks task as completed on a date" do
      t = Taskit::Task.new("get groceries")
      t.complete(Date.new(2019, 10, 12))
      _(!!t.completed?).must_equal true
      _(t.completion_date).wont_be_nil
    end
  end
end