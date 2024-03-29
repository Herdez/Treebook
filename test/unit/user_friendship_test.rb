require 'test_helper'

class UserFriendshipTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  should belong_to(:user)
  should belong_to(:friend)

  test "that creating a friendship works without raising and exception" do
  	assert_nothing_raised do
  		UserFriendship.create user: users(:Mam), friend: users(:jim)
  	end
  end

  test "that creating a friendship based on a user id and friend id works" do
  	UserFriendship.create user_id: users(:Mam).id, friend_id: users(:jim).id
  	assert users(:Mam).pending_friends.include?(users(:jim))

  end	

  context "a new instance" do
    setup do
      @user_friendship = UserFriendship.new user: users(:Mam), friend: users(:jim)
    end

    should "have a pending state" do
      assert_equal 'pending', @user_friendship.state
    end

  end

  context "#send_request_email" do
    setup do
      @user_friendship = UserFriendship.create user: users(:Mam), friend: users(:jim)
    end

    should "send an email" do
      assert_difference 'ActionMailer::Base.deliveries.size', 1 do
        @user_friendship.send_request_email
      end  
    end

  end

  context "#mutual_friendship" do
    setup do
      UserFriendship.request users(:Mam), users(:jim)
      @friendship1 = users(:Mam).user_friendships.where(friend_id: users(:jim).id).first
      @friendship2 = users(:jim).user_friendships.where(friend_id: users(:Mam).id).first

    end

    should "correctly find the mutual friendship" do
      assert_equal @friendship2, @friendship1.mutual_friendship
    end
  end

  context "#accept_mutual_friendship!" do
    setup do
      UserFriendship.request users(:Mam), users(:jim)
    end

    should "accept the mutual friendship" do
      friendship1 = users(:Mam).user_friendships.where(friend_id: users(:jim).id).first
      friendship2 = users(:jim).user_friendships.where(friend_id: users(:Mam).id).first
      
      friendship1.accept_mutual_friendship!
      friendship2.reload
      assert_equal 'accepted', friendship2.state
    end

  end

  context "#accept!" do
    setup do
      @user_friendship = UserFriendship.request users(:Mam), users(:jim)
    end

    should "set the state to accepted" do
      @user_friendship.accept!
      assert_equal "accepted", @user_friendship.state
    end

    should "send an acceptance email" do
      assert_difference 'ActionMailer::Base.deliveries.size', 1 do
        @user_friendship.accept!
      end
    end

    should "include the friend in the list of friends" do
      @user_friendship.accept!
      users(:Mam).friends.reload
      assert users(:Mam).friends.include?(users(:jim))
    end

    should "accept the mutual frienship" do
      @user_friendship.accept!
      assert_equal 'accepted', @user_friendship.mutual_friendship.state
    end

  end

  context ".request" do
    should "create two user freindships" do
      assert_difference 'UserFriendship.count', 2 do
        UserFriendship.request(users(:Mam), users(:jim))
      end
    end

    should "send a friend request email" do
      assert_difference 'ActionMailer::Base.deliveries.size', 1 do
        UserFriendship.request(users(:Mam), users(:jim))
      end
    end

  end

  context "#delete_mutual_friendship!" do
    setup do
      UserFriendship.request users(:Mam), users(:jim)
      @friendship1 = users(:Mam).user_friendships.where(friend_id: users(:jim).id).first
      @friendship2 = users(:jim).user_friendships.where(friend_id: users(:Mam).id).first

    end
    should "delete the mutual friendship" do
      assert_equal @friendship2, @friendship1.mutual_friendship
      @friendship1.delete_mutual_friendship!
      assert !UserFriendship.exists?(@friendship2.id)
    end
  end

  context "on destroy" do
    setup do
      UserFriendship.request users(:Mam), users(:jim)
      @friendship1 = users(:Mam).user_friendships.where(friend_id: users(:jim).id).first
      @friendship2 = users(:jim).user_friendships.where(friend_id: users(:Mam).id).first
    end

    should "delete the mutual friendship" do
      @friendship1.destroy
      assert !UserFriendship.exists?(@friendship2.id)
    end

  end

  context "#block!" do
    setup do
      @user_friendship = UserFriendship.request users(:Mam), users(:jim)
    end

    should "set the state to blocked" do
      @user_friendship.block!
      assert_equal 'blocked', @user_friendship.state
      assert_equal 'blocked', @user_friendship.mutual_friendship.state
    end

    should "not allow new request once blocked" do
      @user_friendship.block!
      uf = UserFriendship.request users(:Mam), users(:jim)
      assert !uf.save
    end

  end

end
