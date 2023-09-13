KDT 파이널프로젝트

PLANI 기업 협업 프로젝트로 사용자 별 구매상품 추천 시스템 모델 개발.

기업에서 제공한 데이터는 총 3개로, 이미 고객군이 분류되어있었고, 데이터 사이즈가 (10000,10000)이며, 상품_ID에 대한 정보가 없어서 깊은 분석을 하기에는 어려웠다.

- MF 추천시스템을 사용하기 위해 장바구니에 담은 데이터에는 rating을 2점, 구매 데이터에는 rating 3점을 부여하였고, user_id를 기준으로 장바구니 데이터와 구매 데이터를 merge
- pivot_table을 matrix로 변환하여, 각 사용자들의 평균 평점을 구한 뒤, user_id와 item_code에 대해 사용자 평균 평점을 뺀 Matrix_User_Mean 데이터프레임을 생성
- SVD를 활용한 MATRIX FACTORIZATION 모델링 진행
- USER_ID 별 상품 추천해주는 함수로 OUTPUT 나오도록 구현.
  - INPUT으로 USER_ID, 상품 정보 TABLE, 평점 TABLE, 추천 개수
  - 최종 OUTPUT : 사용자가 찜, 구매하지 않은 상품에서 평점이 높은 상품을 추천
 
