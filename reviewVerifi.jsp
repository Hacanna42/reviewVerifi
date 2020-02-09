<%@page import="org.jsoup.select.Elements"%>
<%@page import="org.jsoup.Jsoup"%>
<%@page import="org.jsoup.nodes.Document"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>리뷰 알바 검거</title>
</head>
<body>
<%
String title = request.getParameter("movie");
//영화 코드 따오기
		String URL = "https://search.naver.com/search.naver?sm=top_hty&fbm=1&ie=utf8&query=영화 "+title;
		try {
			Document doc = Jsoup.connect(URL).get();
			Elements elem = doc.select("#_au_movie_info > div.info_main > h3 > a");
			String str = elem.toString();
			int cut1 = str.indexOf("code=")+5;
			int cut2 = str.indexOf("\"", cut1);
			String movieCode = str.substring(cut1, cut2);
			System.out.println("MovieCode is "+movieCode);

			//리뷰 따오기
			int pos = 0;
			int neg = 0;
			String temprev = "";
			for (int i=1;i<=10;i++) {
				URL = "https://movie.naver.com/movie/bi/mi/pointWriteFormList.nhn?code="+movieCode+"&type=after&onlyActualPointYn=Y&onlySpoilerPointYn=N&order=sympathyScore&page="+i;
				doc = Jsoup.connect(URL).get();
				elem = doc.select("div.star_score > em");
				str = elem.text();
				System.out.println(str);
				temprev += str+" ";
				Thread.sleep(180);
			}
			String reviews[] = temprev.split(" ");
			int confirmrv = 0;
			//수학 계산
			//평균, 최하 최상점 구하기
			for (int i=0;i<reviews.length;i++) {
				confirmrv += Integer.parseInt(reviews[i]);

				if (Integer.parseInt(reviews[i]) > 8)
					pos++;
				else if (Integer.parseInt(reviews[i]) < 3)
					neg++;
			}
			int averrv = confirmrv/reviews.length;
			double disper = 0;
			double confirmdp = 0;
			//분산 구하기
			for (int i=0;i<reviews.length;i++) {
				disper += Math.pow((Integer.parseInt(reviews[i]) - averrv), 2);
			}
			confirmdp = disper/(reviews.length-1);
			//표준편차 * 10
			confirmdp = Math.sqrt(confirmdp)*10;
			confirmdp = (Math.round(confirmdp*100)/100.0);
			double negperc = (double)neg/(pos+neg)*100;
			negperc = (Math.round(negperc*100)/100.0);
			double posperc = (double)pos/(pos+neg)*100;
			posperc = (Math.round(negperc*100)/100.0);
			double jobrevper = negperc + confirmdp;
			jobrevper = (Math.round(jobrevper*10)/10.0);
			System.out.println(negperc);
			System.out.println(confirmdp);

			//result
			if (pos == 0) {
				jobrevper = 0;
			}
			if (jobrevper >= 100)
				jobrevper = 99.9;
			%><h1><%out.println("<"+title+"> 리뷰알바 확률: "+jobrevper+"%</br>");%></h1><%
			out.println("- 평점 표준편차(낮을수록 좋음): "+Math.round(confirmdp/10*100)/100.0);
			out.println("</br>- 리뷰 알바 확률이 높을수록 리뷰를 신뢰하지 않는 것이 좋습니다.</br>- 확률 수치가 영화의 재미를 판단하는 것은 아닙니다.");

		} catch (Exception e) {
			out.println("영화를 찾을 수 없습니다.</br>제목을 올바르게 입력했는지 확인해주세요.</br>만약 제목을 올바르게 입력했는데도 이런 오류가 발생했다면</br>크롤링 봇이 차단당했거나, 아직 기능을 지원하지 않는 영화입니다.</br>잠시 후 다시 시도해주세요.");
		}
%>
</body>
</html>
