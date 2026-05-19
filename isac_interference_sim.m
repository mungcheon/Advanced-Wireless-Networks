%% Interference Mitigation in 4.9 GHz ISAC Networks
% Multi-domain Resource Management (time/frequency/power) toy simulation
% 실행: MATLAB에서 isac_interference_sim 입력

clear; clc; close all;
rng(7);

%% 시나리오 설정
Nveh = 24;            % 차량 노드 수
Nslot = 120;          % 시간 슬롯 수
Nrb   = 12;           % 주파수 리소스 블록 수

Pmax_dBm = 23;        % 최대 송신 전력
Pmin_dBm = 5;         % 최소 송신 전력
noise_dBm = -96;
SINR_th_dB = 6;       % 통신 성공 임계

fc = 4.9e9;           % 4.9 GHz
c = 3e8;
lambda = c/fc;

% 간단한 도로 위 차량 위치
x = sort(500*rand(Nveh,1));
y = 3*round(rand(Nveh,1));
pos = [x y];

% 통신 링크: 인접 차량 쌍 (i -> i+1)
pairs = [(1:Nveh-1)' (2:Nveh)'];
Nlink = size(pairs,1);

% 레이더 타깃 (각 링크마다 하나의 랜덤 타깃 거리)
Rtarget = 20 + 80*rand(Nlink,1); % m

%% 베이스라인 (무작위 할당)
base = runScheduler(pos, pairs, Nslot, Nrb, Pmin_dBm, Pmax_dBm, ...
    noise_dBm, SINR_th_dB, Rtarget, lambda, false);

%% 제안 방식 (다중 도메인: 시간/주파수/전력)
prop = runScheduler(pos, pairs, Nslot, Nrb, Pmin_dBm, Pmax_dBm, ...
    noise_dBm, SINR_th_dB, Rtarget, lambda, true);

%% 결과 요약 출력
fprintf('\n===== 시뮬레이션 결과 =====\n');
fprintf('베이스라인 통신 성공률: %.2f %%\n', 100*base.successRate);
fprintf('제안 방식 통신 성공률 : %.2f %%\n', 100*prop.successRate);
fprintf('베이스라인 평균 SINR   : %.2f dB\n', base.meanSINR);
fprintf('제안 방식 평균 SINR    : %.2f dB\n', prop.meanSINR);
fprintf('베이스라인 평균 레이더 SNR: %.2f dB\n', base.meanRadarSNR);
fprintf('제안 방식 평균 레이더 SNR : %.2f dB\n', prop.meanRadarSNR);

%% 그림
figure('Color','w');
subplot(1,2,1);
bar([base.successRate prop.successRate]*100);
set(gca,'XTickLabel',{'통신 성공률'});
ylabel('%'); title('성공률 비교'); grid on;

subplot(1,2,2);
bar([base.meanSINR prop.meanSINR; base.meanRadarSNR prop.meanRadarSNR]);
set(gca,'XTickLabel',{'평균 SINR','평균 Radar SNR'});
legend({'Baseline','Proposed'},'Location','best');
ylabel('dB'); title('품질 지표 비교'); grid on;

saveas(gcf,'results_overview.png');

% 결과를 파일로 저장 (초보자 확인용)
summaryTable = table([base.successRate;prop.successRate]*100, ...
    [base.meanSINR;prop.meanSINR], [base.meanRadarSNR;prop.meanRadarSNR], ...
    'VariableNames', {'SuccessRate_percent','MeanSINR_dB','MeanRadarSNR_dB'}, ...
    'RowNames', {'Baseline','Proposed'});
disp('--- 결과 테이블 ---');
disp(summaryTable);
writetable(rows2vars(summaryTable),'results_metrics.csv');
save('results_metrics.mat','base','prop','summaryTable');

%% ---- local function ----
function out = runScheduler(pos, pairs, Nslot, Nrb, Pmin_dBm, Pmax_dBm, ...
    noise_dBm, SINR_th_dB, Rtarget, lambda, smartMode)

Nlink = size(pairs,1);
noise_mW = 10^(noise_dBm/10);

sinrLog = zeros(Nslot,Nlink);
radarLog = zeros(Nslot,Nlink);
succCount = 0;

% 링크 평균 거리 기반 우선순위 (긴 링크 우선)
d = vecnorm(pos(pairs(:,1),:) - pos(pairs(:,2),:),2,2);
[~, prio] = sort(d,'descend');

for t = 1:Nslot
    rbAssign = randi(Nrb,Nlink,1);           % 기본 무작위 RB
    pAssign  = Pmax_dBm*ones(Nlink,1);       % 기본 최대전력

    if smartMode
        % 1) 주파수 도메인: greedy RB 재할당 (강한 간섭 링크 분리)
        rbAssign = greedyRB(Nlink, Nrb, prio);

        % 2) 전력 도메인: 링크 거리 기반 전력 제어
        pAssign = Pmin_dBm + (Pmax_dBm-Pmin_dBm)*normalize(d,'range');

        % 3) 시간 도메인: 일부 링크는 쉬어가며 간섭 감소
        if mod(t,3)==0
            muteIdx = prio(1:floor(0.15*Nlink));
            pAssign(muteIdx) = -Inf; % 무전송
        end
    end

    % 링크별 SINR 계산
    for k = 1:Nlink
        if ~isfinite(pAssign(k))
            sinrLog(t,k) = -Inf;
            radarLog(t,k) = -Inf;
            continue;
        end

        tx = pairs(k,1); rx = pairs(k,2);
        sigd = norm(pos(tx,:) - pos(rx,:));
        Ls = fspl(sigd, lambda);
        Ps = 10^(pAssign(k)/10) / Ls;

        interf = 0;
        for j = 1:Nlink
            if j==k || rbAssign(j)~=rbAssign(k) || ~isfinite(pAssign(j)), continue; end
            txj = pairs(j,1);
            dij = norm(pos(txj,:) - pos(rx,:));
            Lj = fspl(dij, lambda);
            interf = interf + 10^(pAssign(j)/10)/Lj;
        end

        SINR = Ps/(interf + noise_mW);
        sinrLog(t,k) = 10*log10(SINR);
        succCount = succCount + (sinrLog(t,k) >= SINR_th_dB);

        % 레이더 SNR (단순 monostatic 근사)
        sigma = 1; % RCS 가정
        Pr = (10^(pAssign(k)/10) * lambda^2 * sigma)/((4*pi)^3 * Rtarget(k)^4);
        radarLog(t,k) = 10*log10(Pr/noise_mW);
    end
end

validSINR = isfinite(sinrLog);
validRadar = isfinite(radarLog);
out.successRate = succCount / nnz(validSINR);
out.meanSINR = mean(sinrLog(validSINR));
out.meanRadarSNR = mean(radarLog(validRadar));
end

function rb = greedyRB(Nlink, Nrb, prio)
rb = zeros(Nlink,1);
loadPerRb = zeros(Nrb,1);
for ii = 1:Nlink
    k = prio(ii);
    [~, id] = min(loadPerRb);
    rb(k) = id;
    loadPerRb(id) = loadPerRb(id)+1;
end
end

function L = fspl(d, lambda)
% 간단 자유공간 경로손실 (선형 스케일)
d = max(d,1);
L = (4*pi*d/lambda)^2;
end