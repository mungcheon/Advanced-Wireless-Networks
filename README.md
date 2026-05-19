# Advanced-Wireless-Networks
수업 실습용

## MATLAB 실습: 4.9 GHz ISAC 간섭완화 (과제용 확장 버전)

논문 **"Interference Mitigation in 4.9 GHz ISAC Networks: A Multi-domain Resource Management Approach"**의 핵심 개념을 바탕으로,
MATLAB에서 직접 실험 가능한 형태로 구성한 코드입니다.

> ⚠️ 중요: 이 저장소 코드는 논문 저자 공식 공개코드가 아니라, 논문 아이디어를 따라 만든 **수업/과제용 구현**입니다.

---

## 1) 어떤 파일을 실행하면 되나요?

- 메인 스크립트: `isac_interference_sim.m`

MATLAB Command Window에서 아래처럼 실행합니다.

```matlab
isac_interference_sim
```

실행 후:
- 콘솔 결과 출력
- `results_overview.png` 저장

---

## 2) 코드가 무엇을 비교하나요?

동일한 차량/링크 환경에서 아래 2개 스케줄러를 비교합니다.

1. **Baseline**
   - RB(주파수 블록) 무작위 할당
   - 항상 최대 송신전력 사용
2. **Proposed (Multi-domain)**
   - 주파수 도메인: Greedy RB 분산
   - 전력 도메인: 링크 거리 기반 전력제어
   - 시간 도메인: 일부 링크 주기적 mute

즉, “time + frequency + power”를 동시에 조절하면 간섭이 얼마나 줄어드는지 보는 구조입니다.

---

## 3) MATLAB 초보가 꼭 확인할 포인트

실행 후 아래를 순서대로 확인하면 됩니다.

### A. 통신 성공률 (Success Rate)
- 출력 예: `베이스라인 통신 성공률`, `제안 방식 통신 성공률`
- 의미: SINR 임계값(기본 6 dB) 이상인 링크 비율
- 확인 포인트: 제안 방식이 보통 더 높아야 정상

### B. 평균 SINR
- 출력 예: `베이스라인 평균 SINR`, `제안 방식 평균 SINR`
- 의미: 통신 품질의 평균 지표
- 확인 포인트: 제안 방식이 baseline 대비 높아지면 간섭 완화 효과

### C. 평균 Radar SNR
- 출력 예: `베이스라인 평균 레이더 SNR`, `제안 방식 평균 레이더 SNR`
- 의미: sensing 성능(단순 근사 모델)
- 확인 포인트: 통신 성능 개선과 sensing 성능 간 균형 확인

### D. 저장된 그래프 파일
- 파일: `results_overview.png`
- 막대 그래프에서 Baseline vs Proposed를 직관적으로 비교

---

## 4) 파라미터 바꿔가며 실험하는 방법 (추천)

`isac_interference_sim.m` 상단 파라미터를 바꾸면 됩니다.

- `Nveh` (차량 수): 24 → 40 (혼잡도 증가)
- `Nrb` (자원 블록 수): 12 → 8 (주파수 자원 부족)
- `SINR_th_dB`: 6 → 10 (성공 조건 강화)
- `Nslot`: 120 → 300 (통계 안정성 향상)

추천 실험 시나리오:
1. 차량 수 증가 시 간섭 급증 구간 찾기
2. RB 감소 시 proposed 이득이 커지는지 확인
3. 임계 SINR를 높였을 때 성공률 하락 폭 비교

---

## 5) 결과 해석 시 주의점

- 이 코드는 **간소화 모델**입니다.
- 실제 논문 재현에는 추가 항목이 필요합니다.
  - 정교한 채널 모델(Shadowing/Fading)
  - 논문 목적함수/제약식 기반 최적화
  - 반복 실험(Monte-Carlo)과 신뢰구간
