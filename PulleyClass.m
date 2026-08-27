classdef PulleyClass < handle
    properties
        l_min %from calc
        l_max_ratio %from edit field
        l_free %from calc
        minAngle %q_min from config file
        maxAngle %q_max from config file
        alpha_passive_zero % from calc
        r_active %from config file
        r_passive %from config file
        active_center_pos %from calc
        active_touch_pos %from calc
        active_top_pos %from edit field

        tendon_diameter %from config file
        pulley_id %either 'i' for inner or 'o' for outer -> given in joint init
        pulley_type = 's' %either 's' for shoulder or 'a' for arm -> from edit field
        tendon_id = 'n' %either 'r' for red, 'b' for blue or 'n' for not assigned -> use button to swap them
        pulley_numbers_angles %array of angle values for each id number -> calculated in class -> snapped to the next possible configuration position
        pulley_numbers_angles_2 %array of angle values for each id number -> -> snapped to the previously possible configuration position
        pulley_numbers_switch = 0 %used to swap between the snap positions -> 0 = pulley_numbers_angles; 1 = pulley_numbers_angles_2
        active_top_indicator = "+x"
        pretensioning %integer that gives % value

        l_max
        revolutions
        zero_config
        alpha_touch_top %angle from start of touching active pulley to the top positition
        alpha_active %angle of tendon touching active pulley (without adjusting for possible configuration positions and increase of diameter when tendon is overlapping)
        alpha_active_mounted %angle of tendon touching active pulley after adjusting for possible configuration positions -> (1) next possible configuration; (2) previous possible configuration
        alpha_active_reduced %angle from top position to the mount position (on the last rotation)
        active_rotations 
        rotation_direction %"c" = for tightening in clock wise direction; "cc" = counter-clockwise
    end

    methods
        function success = calcActiveZeroAngle(obj)
            success = true;

            r_active_adj = obj.r_active + obj.tendon_diameter/2;
            r_passive_adj = obj.r_passive + obj.tendon_diameter/2;
            adj_max_ratio = obj.l_max_ratio/(1+obj.pretensioning/100);
            
            obj.l_max = obj.l_min*adj_max_ratio;
            l_0 = obj.l_min + (obj.l_max-obj.l_min)*(abs(obj.minAngle)/(abs(obj.maxAngle) + abs(obj.minAngle)));
            
            l_passive_0 = obj.alpha_passive_zero*r_passive_adj;
            l_active_0 = l_0 - l_passive_0 - obj.l_free;
            obj.alpha_active = l_active_0/r_active_adj;
            alpha_active_zero = obj.alpha_active;

            rotations = 0;
            if alpha_active_zero > 2*pi
                alpha_check = alpha_active_zero;
                %alpha_active_zero = 0;
                l_active_0_rest = l_active_0;
                d_add = 0;
                while alpha_check > 2*pi
                    l_sub = 2*pi*(r_active_adj + obj.tendon_diameter*d_add);
                    l_active_0_rest = l_active_0_rest - l_sub;
                    %alpha_active_zero = alpha_active_zero + l_sub/(obj.r_active + 5*d_add);
                    d_add = d_add + 1;
                    alpha_check = l_active_0_rest/(r_active_adj + obj.tendon_diameter*d_add);
                end
                alpha_active_zero = alpha_check;
                rotations = d_add;
            end

            
            oversized = obj.determinOversized();

            dist_1 = obj.dist(obj.active_center_pos,obj.active_touch_pos);
            dist_2 = obj.dist(obj.active_center_pos, obj.active_top_pos);
            dist_3 = obj.dist(obj.active_touch_pos, obj.active_top_pos);
            alpha_active_top = acos((dist_1^2+dist_2^2-dist_3^2)/(2*dist_1*dist_2));
            if oversized == true
                alpha_active_top = 2*pi - alpha_active_top;
            end
            obj.alpha_touch_top = alpha_active_top;

            target = obj.active_rotations*2*pi+obj.alpha_active_reduced;
            i = 0;
            while i < target
                i = i + pi/4;
            end
            obj.alpha_active_mounted(1) = i + obj.alpha_touch_top;
            obj.alpha_active_mounted(2) = i - pi/4 + obj.alpha_touch_top;

            %alpha_active_top
            alpha_active_mount_zero = alpha_active_zero - alpha_active_top;
            if alpha_active_mount_zero < 0
                rotations = rotations-1;
                alpha_active_mount_zero = 2*pi+alpha_active_mount_zero;
                if alpha_active_mount_zero < 0 || rotations < 0  
                    success = false;
                    return
                end
            end
            obj.alpha_active_reduced = alpha_active_mount_zero;
            obj.active_rotations = rotations;

%             l_active_0_rest = l_active_0
%             l_sub = 2*pi*(obj.r_active + 0)
%             angle_1 = l_sub / obj.r_active
%             l_active_0_rest = l_active_0_rest - l_sub
%             angle_2 = l_active_0_rest / (obj.r_active + 5)
%             angle_manual = angle_1 + angle_2
% 
%             alpha_active_zero
            
        
            %obj.active_center_pos
            %obj.active_touch_pos
            

            step_size = pi/4;
            %possible_configs = [step_size*0,step_size*1,step_size*2,step_size*3,step_size*4,step_size*5,step_size*6,step_size*7]
            possible_configs = 0:step_size:7*step_size;
            alpha_config = -10;
            %alpha_active_mount_zero = pi/4*7
            %alpha_active_mount_zero
            for i=1:8
                diff = possible_configs(i) - alpha_active_mount_zero;
                if diff < step_size && diff >= 0 
                    alpha_config = possible_configs(i);
                    zero_config_iter = i;
                    break
                end
            end

            if alpha_config == -10
                alpha_config = 0;
                zero_config_iter = 1;
                rotations = rotations + 1;
            end
            
            %alpha_config = pi/4;
            %alpha_config = 0;
            obj.transformAngleToConfig(alpha_config, zero_config_iter)
            obj.revolutions = rotations;
        end

        function pulley_config = transformAngleToConfig(obj, alpha, config_iter)
            if obj.tendon_id == 'b'
                obj.pulley_numbers_angles = obj.pulley_numbers_angles + alpha;
                obj.pulley_numbers_angles_2 = obj.pulley_numbers_angles_2 + alpha;
            else
                obj.pulley_numbers_angles = obj.pulley_numbers_angles - alpha;
                obj.pulley_numbers_angles_2 = obj.pulley_numbers_angles_2 - alpha;
            end

            if obj.pulley_type == 's'
                if obj.pulley_id == 'i'
                    if obj.tendon_id == 'r'
                        conf_1 = mod(config_iter+3,8)+1;
                        conf_2 = mod(config_iter+4,8)+1;
                    else
                        conf_1 = 9-(mod(config_iter+2,8)+1);
                        conf_2 = 9-(mod(config_iter+1,8)+1);
                    end
                else
                    if obj.tendon_id == 'r'
                        conf_1 = 9-(mod(config_iter+1,8)+1);
                        conf_2 = 9-(mod(config_iter+2,8)+1);
                    else
                        conf_1 = mod(config_iter+4,8)+1;
                        conf_2 = mod(config_iter+3,8)+1;
                    end
                end
                
                %obj.zero_config = [config_iter config_iter+1];
            else
                if obj.pulley_id == 'i'
                    if obj.tendon_id == 'r'
                        conf_1 = mod(config_iter+5,8)+1;
                        conf_2 = mod(config_iter+6,8)+1;
                    else
                        conf_1 = 9-(mod(config_iter+8,8)+1);
                        conf_2 = 9-(mod(config_iter+7,8)+1);
                    end
                else
                    if obj.tendon_id == 'r'
                        conf_1 = 9-(mod(config_iter+7,8)+1);
                        conf_2 = 9-(mod(config_iter+8,8)+1);
                    else
                        conf_1 = mod(config_iter+6,8)+1;
                        conf_2 = mod(config_iter+5,8)+1;
                    end
                end
            end

            obj.zero_config = [conf_1 conf_2];
        end

        function oversized = determinOversized(obj)
            oversized = false;
            touch_angle = atan2(obj.active_touch_pos(2)-obj.active_center_pos(2), obj.active_touch_pos(1)-obj.active_center_pos(1));
            top_angle = atan2(obj.active_top_pos(2)-obj.active_center_pos(2), obj.active_top_pos(1)-obj.active_center_pos(1));

            if touch_angle < 0 
                touch_angle = 2*pi + touch_angle;
            end
            if top_angle < 0
                top_angle = 2*pi + top_angle;
            end

            if obj.tendon_id == 'b'
                min_angle = touch_angle - pi;
                if min_angle < 0
                    min_angle = 2*pi+min_angle;
                    if top_angle < min_angle && top_angle > touch_angle
                        oversized = true;
                    end
                else
                    if top_angle < min_angle || top_angle > touch_angle
                        oversized = true;
                    end
                end
            else
                max_angle = touch_angle + pi;
                if max_angle > 2*pi
                    max_angle = max_angle - 2*pi;
                    if top_angle > max_angle && top_angle < touch_angle
                        oversized = true;
                    end
                else
                    if top_angle > max_angle || top_angle < touch_angle
                        oversized = true;
                    end
                end
            end

            
        end

        function [distance] = dist(~, pos_1, pos_2)
            distance = sqrt((pos_1(1) - pos_2(1))^2+(pos_1(2)-pos_2(2))^2);
        end

        function slope = calcSlope(~,x1,y1,x2,y2)
            d = (y2-y1)/(x2-x1);
            slope = atan(d);
        end

    end

end