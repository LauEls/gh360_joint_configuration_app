classdef ShoulderPitchTendonClass < TendonClass
    properties
        %center position of the middle pulley between the active and
        %passive pulley
        x_middle_pos;
        y_middle_pos;
        z_middle_pos;
        r_middle;
        %attachment position on the passive pulley for the upper tendon
        x_tendon_upper_pos;
        y_tendon_upper_pos;
        z_tendon_upper_pos;
        %attachment position on the passive pulley for the lower tendon
        x_tendon_lower_pos;
        y_tendon_lower_pos;
        z_tendon_lower_pos;

        x_2D_tendon_upper_pos
        y_2D_tendon_upper_pos
        x_2D_tendon_lower_pos
        y_2D_tendon_lower_pos
        x_2D_middle_center
        y_2D_middle_center

        x_free_middle_active_blue
        y_free_middle_active_blue
        x_free_middle_passive_blue
        y_free_middle_passive_blue

        theta_middle
        alpha_middle_blue
        l_free_blue
        l_free_red

        tendon_attachment_indicator = 'n'
    end

    methods
        function [tendon_length_lower,tendon_length_upper] = calc_tendon_length(obj,r_active,r_passive,r_middle)
            x_c_active = obj.x_2D_active_center;
            y_c_active = obj.y_2D_active_center;
            x_c_passive = obj.x_2D_passive_center;
            y_c_passive = obj.y_2D_passive_center;
            x_c_middle = obj.x_2D_middle_center;
            y_c_middle = obj.y_2D_middle_center;
            x_tendon_passive_upper = obj.x_2D_tendon_upper_pos;
            y_tendon_passive_upper = obj.y_2D_tendon_upper_pos;
            x_tendon_passive_lower = obj.x_2D_tendon_lower_pos;
            y_tendon_passive_lower = obj.y_2D_tendon_lower_pos;
            

            %calculate the center distance between active and passive
            %pulley
            center_dist_active_passive = sqrt((x_c_passive-x_c_active)^2+(y_c_passive-y_c_active)^2);
            %calculate the center distance between active and middle pulley
            center_dist_active_middle = sqrt((x_c_middle-x_c_active)^2+(y_c_middle-y_c_active)^2);
            %calculate the center distance between passive and middle
            %pulley
            center_dist_passive_middle = sqrt((x_c_passive-x_c_middle)^2+(y_c_passive-y_c_middle)^2);
            %angle between x-axis and tendon attachment position for
            %different pulley pairs
            theta_active_passive = acos((r_passive-r_active)/center_dist_active_passive); 
            theta_active_middle = asin((r_middle+r_active)/center_dist_active_middle);
            theta_passive_middle = asin((r_passive+r_middle)/center_dist_passive_middle);
            %adjusting angles because the pulley centers are not alligned
            %on one axis
            theta_active_middle_upper = theta_active_middle + atan2(y_c_middle-y_c_active, x_c_middle-x_c_active) - pi/2;
            theta_passive_middle_upper = -theta_passive_middle + atan2(y_c_middle-y_c_passive, x_c_middle-x_c_passive) + pi/2;
            theta_active_passive_lower = theta_active_passive - atan2(y_c_active-y_c_passive, x_c_active-x_c_passive);
            obj.theta_red = theta_active_passive_lower;
            obj.theta_blue = theta_passive_middle_upper;
            obj.theta_middle = theta_passive_middle_upper+pi;
            
            %calculating the position where the tendon start touching the
            %pulley (tendon attachment position) on the active pulley
            x_free_active_lower = x_c_active + r_active*cos(theta_active_passive_lower);
            y_free_active_lower = y_c_active - r_active*sin(theta_active_passive_lower);
            x_free_active_upper = x_c_active + r_active*cos(theta_active_middle_upper);
            y_free_active_upper = y_c_active + r_active*sin(theta_active_middle_upper);
            %for visualization purposes
            obj.x_free_active_blue = x_free_active_upper;
            obj.y_free_active_blue = y_free_active_upper;
            obj.x_free_active_red = x_free_active_lower;
            obj.y_free_active_red = y_free_active_lower;

            %calculating the tendon attachment position on the middle
            %pulley
            x_free_middle_active = x_c_middle + r_middle*cos(theta_active_middle_upper + pi);
            y_free_middle_active = y_c_middle + r_middle*sin(theta_active_middle_upper + pi);
            x_free_middle_passive = x_c_middle + r_middle*cos(theta_passive_middle_upper + pi);
            y_free_middle_passive = y_c_middle + r_middle*sin(theta_passive_middle_upper + pi);
            %for visualization purposes
            obj.x_free_middle_active_blue = x_free_middle_active;
            obj.y_free_middle_active_blue = y_free_middle_active;
            obj.x_free_middle_passive_blue = x_free_middle_passive;
            obj.y_free_middle_passive_blue = y_free_middle_passive;

            %calculating the tendon attachment position on the passive
            %pulley
            x_free_passive_lower = x_c_passive + r_passive*cos(theta_active_passive_lower);
            y_free_passive_lower = y_c_passive - r_passive*sin(theta_active_passive_lower);
            x_free_passive_upper = x_c_passive + r_passive*cos(theta_passive_middle_upper);
            y_free_passive_upper = y_c_passive + r_passive*sin(theta_passive_middle_upper);
            %for visualization purposes
            obj.x_free_passive_blue = x_free_passive_upper;
            obj.y_free_passive_blue = y_free_passive_upper;
            obj.x_free_passive_red = x_free_passive_lower;
            obj.y_free_passive_red = y_free_passive_lower;

            %calculating the lengths for the free hanging tendon section
            %for the different pulley pairs
            l_free_active_passive_lower = sqrt((x_free_passive_lower-x_free_active_lower)^2+(y_free_passive_lower-y_free_active_lower)^2);
            l_free_active_middle_upper = sqrt((x_free_active_upper-x_free_middle_active)^2+(y_free_active_upper-y_free_middle_active)^2);
            l_free_passive_middle_upper = sqrt((x_free_passive_upper-x_free_middle_passive)^2+(y_free_passive_upper-y_free_middle_passive)^2);

            %calculating the angle between the position where the tendon
            %starts touching the pulley and the tendon attachment position
            %on the passive pulley
            dist_c_free_lower = sqrt((x_c_passive - x_free_passive_lower)^2+(y_c_passive-y_free_passive_lower)^2);
            dist_c_tendon_lower = sqrt((x_c_passive - x_tendon_passive_lower)^2+(y_c_passive-y_tendon_passive_lower)^2);
            dist_free_tendon_lower = sqrt((x_free_passive_lower - x_tendon_passive_lower)^2+(y_free_passive_lower-y_tendon_passive_lower)^2);
            dist_c_free_upper = sqrt((x_c_passive - x_free_passive_upper)^2+(y_c_passive-y_free_passive_upper)^2);
            dist_c_tendon_upper = sqrt((x_c_passive - x_tendon_passive_upper)^2+(y_c_passive-y_tendon_passive_upper)^2);
            dist_free_tendon_upper = sqrt((x_free_passive_upper - x_tendon_passive_upper)^2+(y_free_passive_upper-y_tendon_passive_upper)^2);
            alpha_passive_lower = acos((dist_c_tendon_lower^2+dist_c_free_lower^2-dist_free_tendon_lower^2)/(2*dist_c_free_lower*dist_c_tendon_lower));
            alpha_passive_upper = acos((dist_c_tendon_upper^2+dist_c_free_upper^2-dist_free_tendon_upper^2)/(2*dist_c_free_upper*dist_c_tendon_upper));
            
            %check if the tendon attachment position is earlier than when
            %the tendon would touch the pulley if wrapped around the pulley
            %TODO: add the automatic detection
            %alpha_passive_lower = 0;
%             lower_free_angle = obj.calcAngle();
%             lower_attachment_angle = obj.calcAngle();
%             if lower_free_angle < lower_attachment_angle
%                 alpha_passive_lower = 0;
%             end
%             upper_free_angle = obj.calcAngle();
%             upper_attachment_angle = obj.calcAngle();
%             if upper_free_angle < upper_attachment_angle
%                 alpha_passive_upper = 0;
%             end

            obj.alpha_passive_red = alpha_passive_lower;
            obj.alpha_passive_blue = alpha_passive_upper;
            
            %calculate the angle between where the tendon start and stops
            %touching the middle pulley
            dist_c_free_active = sqrt((x_c_middle - x_free_middle_active)^2+(y_c_middle - y_free_middle_active)^2);
            dist_c_free_passive = sqrt((x_c_middle - x_free_middle_passive)^2+(y_c_middle - y_free_middle_passive)^2);
            dist_active_passive = sqrt((x_free_middle_passive - x_free_middle_active)^2+(y_free_middle_passive - y_free_middle_active)^2);
            alpha_middle = acos((dist_c_free_passive^2+dist_c_free_active^2-dist_active_passive^2)/(2*dist_c_free_active*dist_c_free_passive));
            obj.alpha_middle_blue = alpha_middle;
            
            %calculate the total tendon lengths
            l_active = r_active*(pi/2);
            l_passive_lower = r_passive*(-alpha_passive_lower+obj.maxAngle);
            l_passive_upper = r_passive*(alpha_passive_upper-obj.minAngle);
            l_middle = r_middle*(alpha_middle);
            %l_total_ = l_active + l_free + l_passive;
            tendon_length_lower = l_active + l_free_active_passive_lower + l_passive_lower;
            tendon_length_upper = l_active + l_free_active_middle_upper + l_middle + l_free_passive_middle_upper + l_passive_upper;
            
            obj.l_free_blue = l_free_active_middle_upper + l_middle + l_free_passive_middle_upper;
            obj.l_free_red = l_free_active_passive_lower;
            obj.red_tendon_length = tendon_length_lower;
            obj.blue_tendon_length = tendon_length_upper;
            
        end

        function angle = calcAngle(obj, outer_pos_1, outer_pos_2, center_pos)
            dist_1 = sqrt((center_pos(1) - outer_pos_1(1))^2+(center_pos(2)-outer_pos_1(2))^2);
            dist_2 = sqrt((center_pos(1) - outer_pos_2(1))^2+(center_pos(2)-outer_pos_2(2))^2);
            dist_3 = sqrt((outer_pos_1(1) - outer_pos_2(1))^2+(outer_pos_1(2)-outer_pos_2(2))^2);

            angle = acos((dist_2^2+dist_1^2-dist_3^2)/(2*dist_1*dist_2));
        end

        function visualize(obj)
            %visualization
            figure("Name",obj.name);
            hold on;

            %alpha_passive_upper
            %theta_passive_middle_upper
            base_angle_upper = alpha_passive_upper+theta_passive_middle_upper;
            x_tendon_attachment_upper = x_c_passive + r_passive * cos(base_angle_upper);
            y_tendon_attachment_upper = y_c_passive + r_passive * sin(base_angle_upper);
            x_max_upper = x_c_passive + r_passive * cos(base_angle_upper-obj.maxAngle);
            y_max_upper = y_c_passive + r_passive * sin(base_angle_upper-obj.maxAngle);
            x_min_upper = x_c_passive + r_passive * cos(base_angle_upper-obj.minAngle);
            y_min_upper = y_c_passive + r_passive * sin(base_angle_upper-obj.minAngle);

            %alpha_passive_lower
            %theta_active_passive_lower
            base_angle_lower = alpha_passive_lower - theta_active_passive_lower;
            x_tendon_attachment_lower = x_c_passive + r_passive * cos(base_angle_lower);
            y_tendon_attachment_lower = y_c_passive + r_passive * sin(base_angle_lower);
            x_max_lower = x_c_passive + r_passive * cos(base_angle_lower-obj.maxAngle);
            y_max_lower = y_c_passive + r_passive * sin(base_angle_lower-obj.maxAngle);
            x_min_lower = x_c_passive + r_passive * cos(base_angle_lower-obj.minAngle);
            y_min_lower = y_c_passive + r_passive * sin(base_angle_lower-obj.minAngle);

            
%             top_inc = base_angle + top_angle;
%             bot_inc = base_angle - bot_angle;
%             x_tendon_attachment = x_c_passive + r_passive * cos(base_angle);
%             y_tendon_attachment = y_c_passive + r_passive * sin(base_angle);
%             x_top_max = x_c_passive + r_passive * cos(top_inc);
%             y_top_max = y_c_passive + r_passive * sin(top_inc);
%             x_bot_max = x_c_passive + r_passive * cos(bot_inc);
%             y_bot_max = y_c_passive + r_passive * sin(bot_inc);

            passive_circle = nsidedpoly(1000, 'Center', [x_c_passive y_c_passive], 'Radius', r_passive);
            active_circle = nsidedpoly(1000, 'Center', [x_c_active y_c_active], 'Radius', r_active);
            middle_circle = nsidedpoly(1000, 'Center', [x_c_middle y_c_middle], 'Radius', r_middle);
            plot(passive_circle, 'FaceColor', 'r')
            plot(active_circle, 'FaceColor', 'r')
            plot(middle_circle, 'FaceColor', 'r')
            plot(x_free_passive_lower,y_free_passive_lower,'bX')
            plot(x_free_active_lower,y_free_active_lower,'bX')
            plot(x_free_active_upper,y_free_active_upper, 'rX')
            plot(x_free_passive_upper,y_free_passive_upper, 'rX')
            plot(x_free_middle_active,y_free_middle_active, 'rX')
            plot(x_free_middle_passive,y_free_middle_passive, 'rX')
            plot([x_free_passive_lower x_free_active_lower], [y_free_passive_lower y_free_active_lower], 'b')
            plot([x_free_active_upper x_free_middle_active], [y_free_active_upper y_free_middle_active], 'r')
            plot([x_free_passive_upper x_free_middle_passive], [y_free_passive_upper y_free_middle_passive], 'r')

            plot(x_tendon_attachment_upper, y_tendon_attachment_upper, 'rO')
            %plot(-397.189, 223.896, 'r+')
            plot(x_max_upper, y_max_upper, 'r+')
            plot(x_min_upper, y_min_upper, 'r+')

            plot(x_tendon_attachment_lower, y_tendon_attachment_lower, 'bO')
            %plot(-345.617, 169.373, 'b+')
            plot(x_max_lower, y_max_lower, 'b+')
            plot(x_min_lower, y_min_lower, 'b+')

            axis equal
        end

        function [new_tendon_length_1, new_tendon_length_2] = calcTendonLength(obj)
            %reassigning parameters into a new x/y coordinate system
            obj.x_2D_active_center = obj.coordinate_assignment(obj.x_active_pos, obj.y_active_pos, obj.z_active_pos, obj.x_coordinate_id);
            obj.y_2D_active_center = obj.coordinate_assignment(obj.x_active_pos, obj.y_active_pos, obj.z_active_pos, obj.y_coordinate_id);
            obj.x_2D_passive_center = obj.coordinate_assignment(obj.x_passive_pos, obj.y_passive_pos, obj.z_passive_pos, obj.x_coordinate_id);
            obj.y_2D_passive_center = obj.coordinate_assignment(obj.x_passive_pos, obj.y_passive_pos, obj.z_passive_pos, obj.y_coordinate_id);
            obj.x_2D_tendon_upper_pos = obj.coordinate_assignment(obj.x_tendon_upper_pos, obj.y_tendon_upper_pos, obj.z_tendon_upper_pos, obj.x_coordinate_id);
            obj.y_2D_tendon_upper_pos = obj.coordinate_assignment(obj.x_tendon_upper_pos, obj.y_tendon_upper_pos, obj.z_tendon_upper_pos, obj.y_coordinate_id);
            obj.x_2D_tendon_lower_pos = obj.coordinate_assignment(obj.x_tendon_lower_pos, obj.y_tendon_lower_pos, obj.z_tendon_lower_pos, obj.x_coordinate_id);
            obj.y_2D_tendon_lower_pos = obj.coordinate_assignment(obj.x_tendon_lower_pos, obj.y_tendon_lower_pos, obj.z_tendon_lower_pos, obj.y_coordinate_id);
            obj.x_2D_middle_center = obj.coordinate_assignment(obj.x_middle_pos, obj.y_middle_pos, obj.z_middle_pos, obj.x_coordinate_id);
            obj.y_2D_middle_center = obj.coordinate_assignment(obj.x_middle_pos, obj.y_middle_pos, obj.z_middle_pos, obj.y_coordinate_id);

            %calculating the tendon lengths
            [new_tendon_length_1, new_tendon_length_2] = obj.calc_tendon_length((obj.r_active+obj.tendon_diameter/2), (obj.r_passive+obj.tendon_diameter/2), (obj.r_middle+obj.tendon_diameter/2));
        end
    end
end