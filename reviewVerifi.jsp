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
//영화 코드 따오기
		String URL = "https://search.naver.com/search.naver?sm=top_hty&fbm=1&ie=utf8&query=영화 인셉션";
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
			double jobrevper = negperc + confirmdp;
			jobrevper = (Math.round(jobrevper*10)/10.0);
			System.out.println(negperc);
			System.out.println(confirmdp);

			//result
			if (jobrevper >= 100)
				jobrevper = 99.9;

			out.println("리뷰 알바 확률: "+jobrevper+"%");

		} catch (Exception e) {
			out.println("영화를 찾을 수 없습니다.");
		}
%>
</body>
</html>
