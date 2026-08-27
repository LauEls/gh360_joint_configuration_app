classdef UpperarmRollTendonClass < TendonClass
    properties
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

        tendon_attachment_indicator = 'n'
    end

    methods
        function [tendon_length_lower,tendon_length_upper] = calc_tendon_length(obj,r_active,r_passive)
            x_c_active = obj.x_2D_active_center;
            y_c_active = obj.y_2D_active_center;
            x_c_passive = obj.x_2D_passive_center;
            y_c_passive = obj.y_2D_passive_center;
            x_tendon_passive_upper = obj.x_2D_tendon_upper_pos;
            y_tendon_passive_upper = obj.y_2D_tendon_upper_pos;
            x_tendon_passive_lower = obj.x_2D_tendon_lower_pos;
            y_tendon_passive_lower = obj.y_2D_tendon_lower_pos;

            %distance between the center of the two pulleys
            center_dist = sqrt((x_c_passive-x_c_active)^2+(y_c_passive-y_c_active)^2);
            %calculating the angle between the x-axis and the position
            %where the tendon starts touching the pulley
            theta = acos((r_passive-r_active)/center_dist);  
            %since the two pulleys are not alligned on the same x axis, the
            %theta values have to be adjusted for the upper and lower
            %tendon
            theta_upper = theta + atan2(y_c_active-y_c_passive, x_c_active-x_c_passive);
            theta_lower = theta - atan2(y_c_active-y_c_passive, x_c_active-x_c_passive);
            obj.theta_blue = theta_upper;
            obj.theta_red = theta_lower;
            %calculate the length of the free hanging tendon (where no
            %pulley is touched)
            l_free = center_dist*sin(theta);
            l_free_2 = sqrt(center_dist^2 - (r_passive - r_active)^2);
            
            
            %calculating the positions on the active pulley where the
            %tendon starts touching
            x_free_active_lower = x_c_active + r_active*cos(theta_lower);
            y_free_active_lower = y_c_active - r_active*sin(theta_lower);
            x_free_active_upper = x_c_active + r_active*cos(theta_upper);
            y_free_active_upper = y_c_active + r_active*sin(theta_upper);
            obj.x_free_active_blue = x_free_active_upper;
            obj.y_free_active_blue = y_free_active_upper;
            obj.x_free_active_red = x_free_active_lower;
            obj.y_free_active_red = y_free_active_lower;

    
            %calculating the tendon attachment position on the passive
            %pulley
            x_free_passive_lower = x_c_passive + r_passive*cos(theta_lower);
            y_free_passive_lower = y_c_passive - r_passive*sin(theta_lower);
            x_free_passive_upper = x_c_passive + r_passive*cos(theta_upper);
            y_free_passive_upper = y_c_passive + r_passive*sin(theta_upper);
            obj.x_free_passive_blue = x_free_passive_upper;
            obj.y_free_passive_blue = y_free_passive_upper;
            obj.x_free_passive_red = x_free_passive_lower;
            obj.y_free_passive_red = y_free_passive_lower;


            %Calculating the length of the tendon between pulleys using the
            %distance between the positions where the tendon starts
            %touching the pulley
            l_free_lower = sqrt((x_free_passive_lower-x_free_active_lower)^2+(y_free_passive_lower-y_free_active_lower)^2);
            l_free_upper = sqrt((x_free_passive_upper-x_free_active_upper)^2+(y_free_passive_upper-y_free_active_upper)^2);
            obj.l_free = l_free_lower;

            %calculating the angle between the position where the tendon
            %starts touching the pulley and the tendon attachment position
            %on the pulley
            if obj.tendon_attachment_indicator == 'n'
                x_tendon_lower = x_tendon_passive_lower;
                y_tendon_lower = y_tendon_passive_lower;
                x_tendon_upper = x_tendon_passive_upper;
                y_tendon_upper = y_tendon_passive_upper;
            elseif obj.tendon_attachment_indicator == 'r'
                x_tendon_lower = x_tendon_passive_upper;
                y_tendon_lower = y_tendon_passive_upper;
                x_tendon_upper = x_tendon_passive_lower;
                y_tendon_upper = y_tendon_passive_lower;
            end
            dist_c_free_lower = sqrt((x_c_passive - x_free_passive_lower)^2+(y_c_passive-y_free_passive_lower)^2); %d1
            dist_c_tendon_lower = sqrt((x_c_passive - x_tendon_lower)^2+(y_c_passive-y_tendon_lower)^2); %d2
            dist_free_tendon_lower = sqrt((x_free_passive_lower - x_tendon_lower)^2+(y_free_passive_lower-y_tendon_lower)^2); %d3
            dist_c_free_upper = sqrt((x_c_passive - x_free_passive_upper)^2+(y_c_passive-y_free_passive_upper)^2); %d4
            dist_c_tendon_upper = sqrt((x_c_passive - x_tendon_upper)^2+(y_c_passive-y_tendon_upper)^2); %d5
            dist_free_tendon_upper = sqrt((x_free_passive_upper - x_tendon_upper)^2+(y_free_passive_upper-y_tendon_upper)^2); %d6
            alpha_passive_lower = acos((dist_c_tendon_lower^2+dist_c_free_lower^2-dist_free_tendon_lower^2)/(2*dist_c_free_lower*dist_c_tendon_lower));
            alpha_passive_upper = acos((dist_c_tendon_upper^2+dist_c_free_upper^2-dist_free_tendon_upper^2)/(2*dist_c_free_upper*dist_c_tendon_upper));
            obj.alpha_passive_blue = alpha_passive_upper;
            obj.alpha_passive_red = alpha_passive_lower;    

            if obj.red_alpha_passive_oversized == true
                obj.alpha_passive_red = 2*pi-obj.alpha_passive_red;
            end
            if obj.blue_alpha_passive_oversized == true
                obj.alpha_passive_blue = 2*pi-obj.alpha_passive_blue;
            end
            
            %using the angles on the active and passive pulley, calculate
            %the total tendon length
            l_active = r_active*(pi/2);
            % l_passive_lower = r_passive*(alpha_passive_lower-minAngle);
            % l_passive_upper = r_passive*(alpha_passive_upper+maxAngle);
            % OR 
            l_passive_lower = r_passive*(alpha_passive_lower+obj.maxAngle);
            l_passive_upper = r_passive*(alpha_passive_upper-obj.minAngle);  
            % I'm not sure, but in our case it's the same since we have
            % +180 and -180. 

            %l_total_ = l_active + l_free + l_passive;
            tendon_length_lower = l_active + l_free_lower + l_passive_lower;
            tendon_length_upper = l_active + l_free_upper + l_passive_upper;

            obj.red_tendon_length = tendon_length_lower;
            obj.blue_tendon_length = tendon_length_upper;
        end

        function visualization(obj)
            %visualization
            figure("Name",obj.name);
            hold on;

            %alpha_passive_upper
            %theta_passive_middle_upper
            base_angle_upper = alpha_passive_upper+theta_upper;
            x_tendon_attachment_upper = x_c_passive + r_passive * cos(base_angle_upper);
            y_tendon_attachment_upper = y_c_passive + r_passive * sin(base_angle_upper);
            x_max_upper = x_c_passive + r_passive * cos(base_angle_upper-obj.maxAngle);
            y_max_upper = y_c_passive + r_passive * sin(base_angle_upper-obj.maxAngle);
            x_min_upper = x_c_passive + r_passive * cos(base_angle_upper-obj.minAngle);
            y_min_upper = y_c_passive + r_passive * sin(base_angle_upper-obj.minAngle);

            %alpha_passive_lower
            %theta_active_passive_lower
            base_angle_lower = alpha_passive_lower - theta_lower;
            x_tendon_attachment_lower = x_c_passive + r_passive * cos(base_angle_lower);
            y_tendon_attachment_lower = y_c_passive + r_passive * sin(base_angle_lower);
            x_max_lower = x_c_passive + r_passive * cos(base_angle_lower-obj.maxAngle);
            y_max_lower = y_c_passive + r_passive * sin(base_angle_lower-obj.maxAngle);
            x_min_lower = x_c_passive + r_passive * cos(base_angle_lower-obj.minAngle);
            y_min_lower = y_c_passive + r_passive * sin(base_angle_lower-obj.minAngle);

            passive_circle = nsidedpoly(1000, 'Center', [x_c_passive y_c_passive], 'Radius', r_passive);
            active_circle = nsidedpoly(1000, 'Center', [x_c_active y_c_active], 'Radius', r_active);
            plot(passive_circle, 'FaceColor', 'y')
            plot(active_circle, 'FaceColor', 'g')
            plot(x_free_passive_lower,y_free_passive_lower,'bX')
            plot(x_free_active_lower,y_free_active_lower,'bX')
            plot(x_free_active_upper,y_free_active_upper, 'rX')
            plot(x_free_passive_upper,y_free_passive_upper, 'rX')
            plot([x_free_passive_lower x_free_active_lower], [y_free_passive_lower y_free_active_lower], 'Color','blue', 'LineStyle','--')
            plot([x_free_passive_upper x_free_active_upper], [y_free_passive_upper y_free_active_upper], 'Color', 'red', 'LineStyle','--')
            % plot(x_c_passive,y_c_passive+r_passive,'y*')
            % plot(x_c_passive,y_c_passive-r_passive,'y*')
            % plot(x_c_passive+r_passive*cos(-theta_lower), y_c_passive+r_passive*sin(-theta_lower), 'yX')

            plot(x_tendon_passive_upper, y_tendon_passive_upper, 'rO')
            plot(x_tendon_passive_lower, y_tendon_passive_lower, 'bO')

            plot(x_tendon_attachment_upper, y_tendon_attachment_upper, 'r+')
            plot(x_max_upper, y_max_upper, 'r*')
            plot(x_min_upper, y_min_upper, 'r+')

            plot(x_tendon_attachment_lower, y_tendon_attachment_lower, 'b+')
            plot(x_max_lower, y_max_lower, 'b+')
            plot(x_min_lower, y_min_lower, 'b*')

            legend('Passive pulley', 'Active pulley', 'Free passive lower', 'Free active lower', 'Free active upper', 'Free passive upper', 'Lower free tendon', 'Upper free tendon','Attachment point upper', 'Attachment point lower');
            axis equal
        end

        function [new_tendon_length_lower, new_tendon_length_upper] = calcTendonLength(obj)
            %rotate the 3D coordinates to be aligned in 2D
            [new_x_active_pos, new_y_active_pos, new_z_active_pos] = obj.z_rot(obj.x_active_pos, obj.y_active_pos, obj.z_active_pos, obj.z_angle);
            [new_x_passive_pos, new_y_passive_pos, new_z_passive_pos] = obj.z_rot(obj.x_passive_pos,obj.y_passive_pos,obj.z_passive_pos,obj.z_angle);

            %reassigning parameters into a new x/y coordinate system
            obj.x_2D_active_center = obj.coordinate_assignment(new_x_active_pos, new_y_active_pos, new_z_active_pos, obj.x_coordinate_id);
            obj.y_2D_active_center = obj.coordinate_assignment(new_x_active_pos, new_y_active_pos, new_z_active_pos, obj.y_coordinate_id);
            obj.x_2D_passive_center = obj.coordinate_assignment(new_x_passive_pos, new_y_passive_pos, new_z_passive_pos, obj.x_coordinate_id);
            obj.y_2D_passive_center = obj.coordinate_assignment(new_x_passive_pos, new_y_passive_pos, new_z_passive_pos, obj.y_coordinate_id);
            obj.x_2D_tendon_upper_pos = obj.coordinate_assignment(obj.x_tendon_upper_pos, obj.y_tendon_upper_pos, obj.z_tendon_upper_pos, obj.x_coordinate_id);
            obj.y_2D_tendon_upper_pos = obj.coordinate_assignment(obj.x_tendon_upper_pos, obj.y_tendon_upper_pos, obj.z_tendon_upper_pos, obj.y_coordinate_id);
            obj.x_2D_tendon_lower_pos = obj.coordinate_assignment(obj.x_tendon_lower_pos, obj.y_tendon_lower_pos, obj.z_tendon_lower_pos, obj.x_coordinate_id);
            obj.y_2D_tendon_lower_pos = obj.coordinate_assignment(obj.x_tendon_lower_pos, obj.y_tendon_lower_pos, obj.z_tendon_lower_pos, obj.y_coordinate_id);

            %calculating the tendon lengths
            [new_tendon_length_lower, new_tendon_length_upper] = obj.calc_tendon_length((obj.r_active+obj.tendon_diameter/2), (obj.r_passive+obj.tendon_diameter/2));
        end
    end
end