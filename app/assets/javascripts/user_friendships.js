window.userFriendships = [];

$(document).ready(function() {
	
	$.ajax({
		url: Routes.get_user_friendships_path({format: 'json'}),
		dataType: 'json',
		type: 'GET',
		success: function(data) {
			window.userFriendships = data;
		}
	});


	$('#add-friendship').click(function(event) {
		if (event.preventDefault()){
		  alert('Funciona');

	    }else{ 
	    	

        var addFriendshipBtn = $(this);
		$.ajax({
		  url: Routes.post_user_friendships_path({user_friendship: { friend_id: addFriendshipBtn.data('friendId') }} ),
		  dataType: 'json',
		  type: 'POST',
          success: function(e){
		    addFriendshipBtn.hide();
		    $('#friend-status').html("<a href='#' class='btn btn-success'>Friendship Requested</a>");
		  }
		});


	    }
	});
});