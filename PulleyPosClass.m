classdef PulleyPosClass
    properties
        name
        %max and min Angle of the joint
        maxAngle
        minAngle
        %indicator which rotation direction is positiv/negativ
        %either cw (for clockwise) or ccw (for counterclockwise
        maxAngle_indicator
        %indicator of which tendon is the front tendon
        %either t (for top) or b (for bot) as is displayed in the plot
        frontTendon_indicator
        %length of the inner layer (rubbery filament) in [mm]
        %is the length calculated by the TendonClass
        rubber_length_front
        rubber_length_back
        %muliplication factor of how much long the extended sleeve is
        %compared to the rubber (e.g. 1.5)
        sleeve_scale
        %length of the outer layer of the tendon (the sleeve)
        %is calculated in calcPulleyPos()
        sleeve_length_front
        sleeve_length_back
        %length of the free hanging tendon in [mm]
        l_free
        %radius of the acitve and the passive pulley in [mm]
        r_active
        r_passive
        %position where the tendon starts touching the passive/active
        %pulley in [mm]
        passive_pulley_front_tendon_touch_pos
        passive_pulley_back_tendon_touch_pos
        active_pulley_front_tendon_touch_pos
        active_pulley_back_tendon_touch_pos
        % absolut angle from where the tendon starts touching the passive pulley to
        % where the tendon is attached in [rad]
        passive_pulley_front_zero_angle
        passive_pulley_back_zero_angle
        %center position of the active pulley
        active_center
        %center position of the passive pulley
        passive_center
        %position of where the tendon is attached to the passive pulley
        tendon_passive_mount
    end

    methods
        function [front_pulley_pos,back_pulley_pos] = calcPulleyPos(obj)
            %calculating the length of the outer layer of the tendon (the
            %sleeve)
            obj.sleeve_length_front = obj.rubber_length_front * obj.sleeve_scale;
            obj.sleeve_length_back = obj.rubber_length_back * obj.sleeve_scale;
            %calculating the length of the front and back tendon when the
            %joint is in zero position
            l_front_zero = obj.rubber_length_front + ((obj.sleeve_length_front - obj.rubber_length_front)/2);
            l_back_zero = obj.rubber_length_back + ((obj.sleeve_length_back - obj.rubber_length_back)/2);
            %calculating the length of the part of the tendon which touches
            %the passive pulley in zero position
            l_passive_front_zero = obj.r_passive * obj.passive_pulley_front_zero_angle;
            l_passive_back_zero = obj.r_passive * obj.passive_pulley_back_zero_angle;
            %calculating the length of the part of the tendon which touches
            %the active pulley
            l_active_front_zero = l_front_zero - obj.l_free - l_passive_front_zero; 
            l_active_back_zero = l_back_zero - obj.l_free - l_passive_back_zero;
            %transforms in the length of the tendon touching the active
            %pulley into an angle from where the tendon starts touching to where the tendon needs to be attached in [rad]
            active_angle_front_zero = l_active_front_zero/obj.r_active;
            active_angle_back_zero = l_active_back_zero/obj.r_active;
            
            %identify which way is min and which way is max
            if obj.maxAngle_indicator == 'cw'
                if obj.frontTendon_indicator == 't'
                    front_max = obj.maxAngle;
                    front_min = -obj.minAngle;
                else
                    front_max = -obj.minAngle;
                    front_min = obj.maxAngle;
                end
            else
                if obj.frontTendon_indicator == 'b'
                    front_max = obj.maxAngle;
                    front_min = -obj.minAngle;
                else
                    front_max = -obj.minAngle;
                    front_min = obj.maxAngle;
                end

            end

            %calculate active pulley angles in min and max joint position
            passive_front_tendon_min_angle = obj.passive_pulley_front_zero_angle + front_min;
            passive_back_tendon_min_angle = obj.passive_pulley_back_zero_angle - front_min;
            passive_front_tendon_max_angle = obj.passive_pulley_front_zero_angle - front_max;
            passive_back_tendon_max_angle = obj.passive_pulley_back_zero_angle + front_max;

            l_passive_front_min_angle = obj.r_passive*passive_front_tendon_min_angle;
            l_passive_back_min_angle = obj.r_passive*passive_back_tendon_min_angle;
            l_active_front_min = obj.rubber_length_front - obj.l_free - l_passive_front_min_angle;
            l_active_back_min = obj.sleeve_length_back - obj.l_free - l_passive_back_min_angle;
            active_front_tendon_min_angle = l_active_front_min/obj.r_active;
            active_back_tendon_min_angle = l_active_back_min/obj.r_active;
            
            l_passive_front_max_angle = obj.r_passive*passive_front_tendon_max_angle;
            l_passive_back_max_angle = obj.r_passive*passive_back_tendon_max_angle;
            l_active_front_max = obj.sleeve_length_front - obj.l_free - l_passive_front_max_angle;
            l_active_back_max = obj.rubber_length_back - obj.l_free - l_passive_back_max_angle;
            active_front_tendon_max_angle = l_active_front_max/obj.r_active
            active_back_tendon_max_angle = l_active_back_max/obj.r_active

            %readjust zero angles so that in min and max there is at least
            %90 degrees left on the active pulley


            %transform zero angles into pulley mounting positions

            front_pulley_pos = l_front_zero;
            back_pulley_pos = l_back_zero;

            drawVisuals()
        end

        function drawVisuals(obj)
            figure();
            hold on;
            
            a = acos((obj.passive_pulley_front_tendon_touch_pos(1)-obj.passive_center(1))/obj.r_passive);
            x = obj.passive_center(1) + obj.r_passive * cos(obj.passive_pulley_front_zero_angle+a);
            y = obj.passive_center(2) + obj.r_passive * sin(obj.passive_pulley_front_zero_angle+a);
            plot(x,y,'g*')
            
%             front_touch_x = obj.active_center(1) + obj.r_active * cos(obj.active_pulley_front_tendon_touch_angle);
%             front_touch_y = obj.active_center(2) + obj.r_active * sin(active_pulley_front_tendon_touch_angle);
%             back_touch_x = obj.active_center(1) + obj.r_active * cos(active_pulley_back_tendon_touch_angle);
%             back_touch_y = obj.active_center(2) + obj.r_active * sin(active_pulley_back_tendon_touch_angle);
            
%             plot(front_touch_x,front_touch_y,'r*')
            plot(obj.active_pulley_front_tendon_touch_pos(1),obj.active_pulley_front_tendon_touch_pos(2),'rX')
%             plot(back_touch_x,back_touch_y,'b*')
            plot(obj.active_pulley_back_tendon_touch_pos(1),obj.active_pulley_back_tendon_touch_pos(2),'bX')
            
            passive_circle = nsidedpoly(1000, 'Center', obj.passive_center, 'Radius', obj.r_passive);
            active_circle = nsidedpoly(1000, 'Center', obj.active_center, 'Radius', obj.r_active);
            plot(passive_circle, 'FaceColor', 'r')
            plot(active_circle, 'FaceColor', 'r')
            
            plot(obj.passive_pulley_front_tendon_touch_pos(1),obj.passive_pulley_front_tendon_touch_pos(2),'rX')
            plot(obj.passive_pulley_back_tendon_touch_pos(1),obj.passive_pulley_back_tendon_touch_pos(2),'bX')
            plot(obj.tendon_passive_mount(1),obj.tendon_passive_mount(2),'gX')
            plot(obj.passive_center(1),obj.passive_center(2),'gX')
            
            
            axis equal
            hold off;
        end

    end

end