<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8" session="true" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
      
<!DOCTYPE html>
<html lang="en">
<head>
	<%@ include file="../../templates/head.jsp"%>
	<title>Manage Groups</title>
</head>
<body>
	<%@ include file="../../templates/navbar.jsp"%>
	<div class="container">
		<div class="row">
			<div class="col-sm-6">
				<form id="create-group-form" class="form-inline" method="POST" action="${pageContext.servletContext.contextPath}/admin/group/create">
					<div class="form-group">
						<input id="name" type="text" name="name" placeholder="Group name" class="form-control"/>
					</div>
					<div class="form-group">
						<button type="submit" class="btn btn-primary btn-block">Create</button>
					</div>
				</form>
				<hr/>
			</div>
		</div>
		<div class="row">
			<div class="col-sm-6">
				<h2>Groups</h2>
				<div id="groups-container">
					<c:forEach var="group" items="${groups}">
						<div data-id="${group.id}" class="group-container">
							<h3>${group.name}</h3>
							<ul>
								<c:forEach var="aDish" items="${group.dishes}">
									<li data-id="${aDish.id}" class="draggable">${aDish.name}</li>
								</c:forEach>
							</ul>
						</div>
					</c:forEach>
				</div>
			</div>
			<div class="col-sm-6">
				<h2>Ungrouped Dishes</h2>
				<ul id="dishes-list" style="min-height: 200px; border: gray 1px solid;">
					<c:forEach var="dish" items="${dishes}">
						<li data-id="${dish.id}" class="draggable list-group-item">${dish.name}</li>
					</c:forEach>
				</ul>
			</div>
		</div>
	</div>
	<%@ include file="../../templates/foot.jsp"%>
	<script src="${pageContext.servletContext.contextPath}/jquery-ui/jquery-ui.min.js"></script>
	<script>
		$(function() {
			var baseUrl = "${pageContext.request.contextPath}";
			var failure = true;
			
			/* Drag & Drop */
			var dragArgs = { // Draggable items
					cursor: "crosshair",
					snap: ".group-container, .dishes-list",
					start: function(e,ui){
				    	failure = true; // reset the flag
				    },
				    revert: function () {
				        return failure;
				    }
				};
			var dropArgs = {
					  accept: ".draggable",
					  drop: function(event, ui) {
						  var dishId = ui.draggable.data('id');
						  var groupDiv = $(this);
						  var groupId = groupDiv.data('id');
						  $.ajax({
							  async: false,
							  url : baseUrl+'/admin/group/assign',
							  method: 'POST',
							  data: {
								  group: groupId,
								  dish: dishId
							  },
							  success: function() {
								  groupDiv.find('ul').append('<li id="dish-'+dishId+'" data-id="'+dishId+'" class="draggable">'+ui.draggable.text()+'</li>');
								  groupDiv.find('li#dish-'+dishId).draggable(dragArgs);
								  ui.draggable.remove();
								  failure = false;
							  }
						  });
					  }
				};
			
			$( ".draggable" ).draggable(dragArgs);
			$( ".group-container" ).droppable(dropArgs); // set group (<-)
			$( "#dishes-list" ).droppable({ // unset group (->)
				  accept: ".draggable",
				  drop: function(event, ui) {
					  var dishId = ui.draggable.data('id');
					  var ungroupList = $(this);
					  $.ajax({
						  async: false,
						  url : baseUrl+'/admin/group/unassign',
						  method: 'POST',
						  data: {
							  dish: dishId
						  },
						  success: function() {
							  var id = ui.draggable.data('id');
							  var name = ui.draggable.text();
							  ungroupList.prepend('<li id="dish-'+id+'" data-id="'+id+'" class="draggable list-group-item">'+name+'</li>');
							  ungroupList.find("li#dish-"+id).draggable(dragArgs);
							  ui.draggable.remove();
							  failure = false;
						  }
					  });
				  }
			});
			
			/* AJAX query to create a group */
			$("#create-group-form").submit(function(event){
				event.preventDefault();
				var name = $(this).find('#name').val();
				var form = $(this);
				$.ajax({
					url: form.attr("action"),
					data: {
						name: name
					},
					method: 'POST',
					success: function(data, textStatus, jqXHR ){
						form.removeClass("has-error");
						form.addClass("has-success");
						$("#groups-container").prepend(
							'<div id="group-'+data.id+'"data-id="'+data.id +'" class="group-container">' +
							'<h3>'+ data.name +'</h3><ul></ul></div>'
						);
						$('#group-'+data.id).droppable(dropArgs); // Add to droppable set
					},
					error: function(jqXHR, textStatus, errorThrown) {
						form.removeClass("has-success")
						form.addClass("has-error");
					}
				});
			});
		})
	</script>
</body>
</html>