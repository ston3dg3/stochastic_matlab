function plot_positions(pos,L,BS)
plot(pos(:,1),pos(:,2),'.')
if exist('BS','var')
    hold on
    plot(BS(:,1),BS(:,2),'s',...
        'MarkerEdgeColor','k','MarkerFaceColor','k','MarkerSize',10)
    hold off
end
xlim([0, L]);
ylim([0, L]);
