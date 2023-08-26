clc;
clear all;
close all;
EbdB=-10:2:22;
Eb=10.^(EbdB/10);
No=1;
SNR=2*Eb/No;
SNRdB=10*log10(SNR);
BER=zeros(length(Eb),1);
M=32;
N=16;
nTaps=5;
delaytaps=0:4;
dopplertaps=[0 3 1 2 8];
Ncp=max(delaytaps);
iter=10000;
for i=1:iter
    txbits=randi([0,1],[1,M]);
    h=sqrt(No/2)*(randn(1,nTaps)+1i*randn(1,nTaps));
    Hfreq=fft(h,M);
    Noise=sqrt(1/2)*(rand(1,M)+1i*randn(1,M));
    for ix=1:length(Eb)
        loaded_bits=sqrt(Eb(ix))*(2*txbits-1);
        txsamples=sqrt(M)*ifft(loaded_bits);
        txsamplesCP=[txsamples(M-Ncp+1:M) txsamples];
        for tx=1:nTaps
            Doppler=exp(1i*2*pi/M*(-Ncp:M-1)*dopplertaps(tx)/N);
            rxsamplesCP=rxsamplesCP+h(tx)*circshift(txsamplesCP.*Doppler,[0,delaytaps(tx)]);
        end
        BER(ix)=BER(ix)+sum(decodedbits~=txbits);
    end
end
BER=BER/(M*iter);
semilogy(SNRdB,BER,'r-s','linewidth',3.0,'Markerfacecolor','r','MarkerSize',9.0);
grid on;
hold on;
axis tight;
title('SISO OFDM BER v/s SNR with dopppler');
xlabel('SNR(dB)');
ylabel('BER');