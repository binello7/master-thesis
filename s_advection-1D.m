%%% EXERCISE: SOLVING 1D ADVECTION EQUATION WITH DIFFERENT NUMERICAL SCHEMES %%%
close all
clear all

% SETUP
%{
1: forward in time, backward in space
2: Lax-Friedrichs scheme, froward in time, centered in space
3: leap-frog scheme
4: Lax-Wendroff scheme
%}
scheme = 2


## PROBLEM CONDITIONS 
sim_length     = 20                  %[min]
sim_length     = sim_length * 60;    %[s]
wave_duration  = 60                  %[s]
wave_h_0       = 1.1                 %[m]
wave_amplitude = 0.2

L       = 500 %[m]
u       = 0.5 %[m/s]
CFL     = 0.9 %[-]
Delta_x = [1]%[m]
%Delta_x = [10 5]%[m]
%Delta_x = [16 8 4 2 1 0.5 0.25]
%Delta_x =  [10 5 3 2 1 0.5 0.25]%[m]

% For diffusion evaluation
x_P = prod (Delta_x);  % this ...
t_P = x_P / u;
h_P = zeros (length (Delta_x),1);

comput_time = zeros (length (Delta_x),1);



if ~exist ('h_sim','var')
  for k = 1:length(Delta_x)
    tic();
    % NUMBER OF NODES
    q = ceil(L / Delta_x(k)) + 1

    % NUNBER OF TIME-STEPS
    Delta_t = CFL * Delta_x(k) / u
    p       = sim_length / Delta_t + 1
    f       = pi / wave_duration;
    h_0     = wave_h_0 * ones(p,1);
    
    h_0(1:length(0:Delta_t:wave_duration),1) = wave_h_0 + wave_amplitude * ...
                                            sin(f * (0:Delta_t:wave_duration));


    h_sim      = wave_h_0 * ones (p, q);
    h_sim(:,1) = h_0;

    x_real      = (0:(p-1)) * u * Delta_t;
    h_real      = wave_h_0 * ones (p, length (x_real));
    h_real(:,1) = h_0;



    %### WAVE PROPAGATION SIMULATION: DIFFERENT SCHEMES ###
    switch scheme
    case 1
      t_idx     = 2:q;
      num_speed = u * Delta_t / Delta_x(k);

      for n = 1:p-1 % over time
          
          h_sim(n+1,t_idx) = h_sim(n,t_idx) * (1 - num_speed) + ...
                             num_speed * h_sim(n,t_idx-1);
      endfor

    case 2
      for n = 1:p-1
        for i = 2:q-1
          h_sim(n+1,i) = 0.5 * (h_sim(n,i+1) + h_sim(n,i-1)) - (u * Delta_t) / (2 * Delta_x) * (h_sim(n,i+1) - h_sim(n,i-1));
          h_sim(n+1,q) = h_sim(n+1,q-1);
        end
      end

    case 3
       for n = 2:p-1
        for i = 2:q-1
          h_sim(n+1,i) = h_sim(n-1,i) - (u * Delta_t) / (Delta_x) * (h_sim(n,i+1) - h_sim(n,i-1));
        end
      end

    case 4
      for n = 1:p-1
        for i = 2:q-1
          h_sim(n+1,i) = h_sim(n,i) - (u * Delta_t) / (2 * Delta_x) * (h_sim(n,i+1) - h_sim(n,i-1)) + (Delta_t * u)^2 / (2 * Delta_x^2) * (h_sim(n,i-1) - 2*h_sim(n,i) + h_sim(n,i+1));
          h_sim(n+1,q) = h_sim(n+1,q-1);
        end
      end
    endswitch
    h_P(k) = max(h_sim(:,x_P/Delta_x(k) + 1));
    comput_time(k,1) = toc();
  end%for
end%if % exist

tot_comput_time = sum(comput_time) / 60 %[min]

%### REAL WAVE PROPAGATION ###
for n = 2:p
    h_real(n,2:n) = h_real(n-1,1:n-1);
end


%### PLOTTING THE RESULTS ###
%## GRID DISCRETIZATION ERROR ##
figure
subplot(2,1,1)
semilogx([Delta_x(end) Delta_x(1)], [wave_h_0 + wave_amplitude wave_h_0 + wave_amplitude], "k", Delta_x, h_P, "ro-")
title("Absolute error")
xlabel("\Delta x [m]")
ylabel("water height at x_P [m]")
%xlim([Delta_x(end) Delta_x(1)])
%ylim([1 1.5])
axis tight
%## COMPUTATIONAL EFFORT TREND ##
subplot(2,1,2)
semilogx(Delta_x, comput_time, "bo-")
title("Computational effort")
xlabel("\Delta x [m]")
ylabel("time [s]")
%xlim([Delta_x(end) Delta_x(1)])
axis tight



## WAVE PROPAGATION GRAPH
figure
hp = plot(0:Delta_x(k):L, h_sim(1,:), '-b;sim;', x_real, h_real(1,:), '-r;real;');
ht = text(L/2, 0.95, sprintf("t = %.0f s", Delta_t - Delta_t));
ylim([0.9 1.4]);
xlim([0 L]);

mkdir frames;
for j = 2:p
  set (hp(1),'ydata',h_sim(j,:));
  set (hp(2),'ydata',h_real(j,:));
  set (ht, 'string', sprintf("t = %.0f s", Delta_t * j - Delta_t));
  pause(10/sim_length);
  
  fprintf('%d ',j-1)     # frame index
  frname = sprintf ('frames/frame-%04d.png',j-1);
  print ('-dpng', '-r300', frname);
  # saves frame as png with 80 dpi resolution
end

#tfig = 200;
#figure
#plot(0:Delta_x(k):L, h_sim(tfig,:), '-b;sim;', x_real, h_real(tfig,:), '-r;real;');
#text(L/2, 0.95, sprintf("t = %.0f s", Delta_t * tfig - Delta_t));
#ylim([0.9 1.4]);
#xlim([0 L]);


system('ffmpeg -f image2 -i frames/frame-%04d.png -vcodec mpeg4 advection.mp4');
disp('');
bidon=input('Frames created ; press <enter> to start assembling');
disp('Video assembled, folder ''frames'' can be erased!')













