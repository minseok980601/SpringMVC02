<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<head>
  <title>Spring MVC01</title>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.4.1/css/bootstrap.min.css">
  <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.6.3/jquery.min.js"></script>
  <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.4.1/js/bootstrap.min.js"></script>
  <script type="text/javascript">
  	$(document).ready(function() {
  		loadList();
  	});
  	function loadList() {
		// 서버와 통신 : 게시판 리스트 가져오기
		$.ajax({
			url : "board/all",
			type : "get",
			dataType : "json",
			success : makeView,
			error : function () {
				alert("error");
			}
		});
	}
  	function makeView(data) {	// data = [{	}, {	}, {	},,,]
		var listHtml = "<table class='table table-bordered'>";
		listHtml += "<tr>";
		listHtml += "<td>번호</td>";
		listHtml += "<td>제목</td>";
		listHtml += "<td>작성자</td>";
		listHtml += "<td>작성일</td>";
		listHtml += "<td>조회수</td>";
		listHtml += "</tr>";
		$.each(data, function (index, obj) {
			listHtml += "<tr>";
			listHtml += "<td>"+obj.idx+"</td>";
			listHtml += "<td id='t"+obj.idx+"'><a href='javascript:goContent("+obj.idx+")'>"+obj.title+"</a></td>";
			listHtml += "<td>"+obj.writer+"</td>";
			listHtml += "<td>"+obj.indate.split(' ')[0]+"</td>";
			listHtml += "<td id='cnt"+obj.idx+"'>"+obj.count+"</td>";
			listHtml += "</tr>";
			
			listHtml += "<tr id='c"+obj.idx+"' style='display:none'>";
			listHtml += "<td>내용</td>";
			listHtml += "<td colspan='4'>";
			listHtml += "<textarea id='ta"+obj.idx+"' readonly rows='7' class='form-control'></textarea>"
			listHtml += "<br/>";
			listHtml += "<span id='ub"+obj.idx+"'><button class='btn btn-success btn-sm' onclick='goUpdateForm("+obj.idx+")'>수정화면</button></span>&nbsp;";
			listHtml += "<button class='btn btn-warning btn-sm' onclick='goDelete("+obj.idx+")'>삭제</button>";
			listHtml += "</td>";
			listHtml += "</tr>";
		});
		
		listHtml += "<tr>";
		listHtml += "<td colspan='5'>";
		listHtml += "<button class='btn btn-primary btn-sm' onclick='goForm()'>글쓰기</button>";
		listHtml += "</td>";	
		listHtml += "</tr>";
		listHtml += "</table>";
		// id가 view인곳에 table이 들어감
		$("#view").html(listHtml);
		
		$("#view").css("display", "block");
		$("#wfrom").css("display", "none");
	}
  	
  	function goForm() {
		$("#view").css("display", "none");	// 감추고
		$("#wfrom").css("display", "block");	// 보이고
	}
  	
  	function goList() {
		$("#view").css("display", "block");
		$("#wfrom").css("display", "none");
	}
  	
  	function goInsert() {
		// var title = $("#title").val();
		// var content = $("content").val();
		// var writer = $("writer").val();
		
		var fData = $("#frm").serialize();	// 폼 안에 있는 모든 데이터를 한줄로 가져옴
		// alert(fData);
		$.ajax({
			url: "board/new" ,
			type: "post" ,
			data: fData ,
			success: loadList ,
			error: function () {
				alert("error");
			}	
		});
		
		// 폼 초기화
		// $("#title").val("");
		// $("#content").val("");
		// $("#writer").val("");
		$("#fclear").trigger("click");	// trigger 프로그램에서 클릭하게 설정
	}
  	
  	function goContent(idx) {	// idx, 10, 9, 8...
  		if($("#c"+idx).css("display")=="none"){		// 닫혀있을경우
  			
  			$.ajax({
  				url: "board/"+idx,
  				type: "get",
  				dataType: "json",
  				success: function (data) {	// data={"content": ~~~}
					$("#ta"+idx).val(data.content);
				},
				error: function () {
					alert("error");
				}
  			});
  			
  			$("#c"+idx).css("display", "table-row");	// 보이게 block이 아닌 table-row로 해야 스타일이 먹힌다.
  			$("#ta"+idx).attr("readonly", true);
  		} else {
  			$("#c"+idx).css("display", "none");	// 감추게함
  			$.ajax({
  				url: "board/count/"+idx,
  				type: "put",
  				dataType: "json",
  				success: function (data) {
					$("#cnt"+idx).text(data.count);
				},
				error: function () {
					alert("error");
				}
  			});
  		}	
	}
  	
  	function goDelete(idx) {
		$.ajax({
			url: "board/"+idx,
			type: "delete",
			success: loadList,
			error: function () {
				alert("error");
			}
		});
	}
  	
  	function goUpdateForm(idx) {	// idx = 10, 7, ...
		$("#ta"+idx).attr("readonly", false);		// attr = attribute readonly를 취소해라 readonly는 style이 아님
		
		var title = $("#t"+idx).text();		// 수정할 제목의 원래 제목을 가져옴
		var newInput = "<input type='text' id='nt"+idx+"' class='form-control' value='"+title+"'/>";
		$("#t"+idx).html(newInput);
		
		var newButton = "<button class='btn btn-info btn-sm' onclick='goUpdate("+idx+")'>수정</button>";		// 수정화면버튼을 수정버튼으로 변경
		$("#ub"+idx).html(newButton);	
  	}
  	
  	// 글 수정을 할려면 data를 json 형태로 만들고 주고받아야함. JSON.stringify
  	// contentType: 'application/json; charset=utf-8'
  	function goUpdate(idx) {
		var title=$("#nt"+idx).val();
		var content=$("#ta"+idx).val();
		$.ajax({
			url: "board/update",
			type: "put",
			contentType:'application/json;charset=utf-8',
			data: JSON.stringify({"idx":idx, "title":title, "content":content}),
			success: loadList,
			error: function () {
				alert("error");
			}
		});
	}
  </script>
</head>
<body>
 
<div class="container">
  <h2>Spring MVC02</h2>
  <div class="panel panel-default">
    <div class="panel-heading">Board</div>
    <div class="panel-body" id="view">Panel Content</div>
    <div class="pannel-body" id="wfrom" style="display: none">
    	<form id="frm">
	    	<table class="table">
	    		<tr>
	    			<td>제목</td>
	    			<td><input type="text" id="title" name="title" class="form-control"/> </td>
	    		</tr>
			    <tr>
	    			<td>내용</td>
	    			<td><textarea rows="7" class="form-control" id="content" name="content"></textarea> </td>
	    		</tr>
	    		<tr>
	    			<td>작성자</td>
	    			<td><input type="text" id="writer" name="writer" class="form-control"/></td>
	    		</tr>
	    		<tr>
	    			<td colspan="2" align="center">
	    				<button type="button" class="btn btn-success btn-sm" onclick="goInsert()">등록</button>
	    				<button type="reset" class="btn btn-warning btn-sm" id="fclear">취소</button>
	    				<button type="button" class="btn btn-info btn-sm" onclick="goList()">리스트</button>
	    			</td>
	    		</tr>
	    	</table>
    	</form>
    </div>
    <div class="panel-footer">인프런_스프1탄_박매일</div>
  </div>
</div>

</body>
</html>