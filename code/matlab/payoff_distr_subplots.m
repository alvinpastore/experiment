close all;
LINEWIDTH = 3;
FONTSIZE=15;

x = [-1000:.01:1000];
y = [0:.01:1000];
lo = normpdf(y,25,17.7);
hi = normpdf(x,100,354);
subplot(1,3,1);
hold on
title('Condition 1');
plot(y,lo,'LineWidth',LINEWIDTH)
plot(x,hi,'LineWidth',LINEWIDTH)
line([0 0], get(gca, 'ylim'),'Color','k','LineWidth',LINEWIDTH-1);
set(gca,'FontSize',FONTSIZE);
ylabel('PDF');
axis([-400 800 0 0.025])
hold off

x = [100:1:2000];
lo = normpdf(x,1225,17.7);
hi = normpdf(x,1300,354);
subplot(1,3,2);
hold on
title('Condition 2');
plot(x,lo,'LineWidth',LINEWIDTH)
plot(x,hi,'LineWidth',LINEWIDTH)
set(gca,'FontSize',FONTSIZE);
axis([800 2000 0 0.025])
legend({'Option Low','Option High'})
xlabel('Payoff value')
hold off

lo = normpdf(x,1225,17.7);
hi = normpdf(x,1300,17.7);
subplot(1,3,3);
hold on
title('Condition 3');
plot(x,lo,'LineWidth',LINEWIDTH)
plot(x,hi,'LineWidth',LINEWIDTH)
set(gca,'FontSize',FONTSIZE);
axis([1100 1500 0 0.025])
hold off