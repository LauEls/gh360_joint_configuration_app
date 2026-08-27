classdef TendonClass < handle
    properties
        %name for identification
        name
        %minimum and maximum angle of the passive joint
        minAngle
        maxAngle
        %center position of active pulley
        x_active_pos
        y_active_pos
        z_active_pos
        %center position of passive pulley
        x_passive_pos
        y_passive_pos
        z_passive_pos
        %correction to allign the coordinates into a 2D space
        z_angle = 0
        %radius of active pulley
        r_active
        %radius of passive pulley
        r_passive
        %tendon attachement position on passive pulley
        x_tendon_pos
        y_tendon_pos
        z_tendon_pos
        %defining which 3D coordinate axis should become the x and y
        %coordinate axis for the 2D calculations
        x_coordinate_id
        y_coordinate_id
        %
        maxAngle_indicator = 'b'
        tendon_diameter
        blue_alpha_passive_oversized = false
        red_alpha_passive_oversized = false

        %Variables Filled by the Class
        x_2D_active_center
        y_2D_active_center
        x_2D_passive_center
        y_2D_passive_center
        x_2D_tendon_pos
        y_2D_tendon_pos

        theta_red
        theta_blue

        x_free_active_red
        y_free_active_red
        x_free_passive_red
        y_free_passive_red
        x_free_active_blue
        y_free_active_blue
        x_free_passive_blue
        y_free_passive_blue

        alpha_passive_red
        alpha_passive_blue
        alpha_active_blue
        red_tendon_length
        blue_tendon_length

        %for pulley config calculation
        l_free
        pos_tendon %identifies which tendon moves the joint in a positive direction and which in a negative
        neg_tendon
        red_passive
    end
    methods
        %rotation around the z axis for angle theta
        function [new_x, new_y, new_z] = z_rot(~,x,y,z,theta)
            %theta = theta + pi;
            new_x = x*cos(theta) + y*sin(theta);
            new_y = -x*sin(theta) + y*cos(theta);
            new_z = z;
        end

        function [value] = coordinate_assignment(~,x,y,z,id)
            switch id
                case 'x'
                    value = x;
                case 'y'
                    value = y;
                case 'z'
                    value = z;
                case '-x'
                    value = -x;
                case '-y'
                    value = -y;
                case '-z'
                    value = -z;
            end
        end

        function [red_tendon,blue_tendon] = calc_tendon_length(obj,r_active,r_passive)
            x_c_active = obj.x_2D_active_center;
            y_c_active = obj.y_2D_active_center;
            x_c_passive = obj.x_2D_passive_center;
            y_c_passive = obj.y_2D_passive_center;
            x_tendon_passive = obj.x_2D_tendon_pos;
            y_tendon_passive = obj.y_2D_tendon_pos;
            %distance between the center of the two pulleys
            center_dist = sqrt((x_c_passive-x_c_active)^2+(y_c_passive-y_c_active)^2);
            %calculating the angle between the x-axis and the position
            %where the tendon starts touching the pulley
            theta = acos((r_passive-r_active)/center_dist);  
            %since the two pulleys are not alligned on the same x axis, the
            %theta values have to be adjusted for the upper and lower
            %tendon
            obj.theta_blue = theta + atan2(y_c_active-y_c_passive, x_c_active-x_c_passive);
            obj.theta_red = theta - atan2(y_c_active-y_c_passive, x_c_active-x_c_passive);

%             obj.theta_red = theta_3;
%             obj.theta_blue = theta_2;
            %calculate the length of the free hanging tendon (where no
            %pulley is touched)
            l_free = center_dist*sin(theta);
            l_free_2 = sqrt(center_dist^2 - (r_passive - r_active)^2);
            
            
            %calculating the positions on the active pulley where the
            %tendon starts touching
            obj.x_free_active_red = x_c_active + r_active*cos(obj.theta_red);
            obj.y_free_active_red = y_c_active - r_active*sin(obj.theta_red);
            obj.x_free_active_blue = x_c_active + r_active*cos(obj.theta_blue);
            obj.y_free_active_blue = y_c_active + r_active*sin(obj.theta_blue);

            %calculating the positing on the passive pulley where the
            %tendon start touching
            obj.x_free_passive_red = x_c_passive + r_passive*cos(obj.theta_red);
            obj.y_free_passive_red = y_c_passive - r_passive*sin(obj.theta_red);          
            obj.x_free_passive_blue = x_c_passive + r_passive*cos(obj.theta_blue);
            obj.y_free_passive_blue = y_c_passive + r_passive*sin(obj.theta_blue);

%             obj.x_free_active_red = x_free_active_1;
%             obj.y_free_active_red = y_free_active_1;
%             obj.x_free_passive_red = x_free_passive_1;
%             obj.y_free_passive_red = y_free_passive_1;
%             obj.x_free_active_blue = x_free_active_2;
%             obj.y_free_active_blue = y_free_active_2;
%             obj.x_free_passive_blue = x_free_passive_2;
%             obj.y_free_passive_blue = y_free_passive_2;
          

            %Calculating the length of the tendon between pulleys using the
            %distance between the positions where the tendon starts
            %touching the pulley
            l_free_3 = sqrt((obj.x_free_passive_red-obj.x_free_active_red)^2+(obj.y_free_passive_red-obj.y_free_active_red)^2);
            l_free_4 = sqrt((obj.x_free_passive_blue-obj.x_free_active_blue)^2+(obj.y_free_passive_blue-obj.y_free_active_blue)^2);
            obj.l_free = l_free_3;

            %calculating the angle between the position where the tendon
            %starts touching the pulley and the tendon attachment position
            %on the pulley
            dist_1 = sqrt((x_c_passive - obj.x_free_passive_red)^2+(y_c_passive-obj.y_free_passive_red)^2);
            dist_2 = sqrt((x_c_passive - x_tendon_passive)^2+(y_c_passive-y_tendon_passive)^2);
            dist_3 = sqrt((obj.x_free_passive_red - x_tendon_passive)^2+(obj.y_free_passive_red-y_tendon_passive)^2);
            dist_4 = sqrt((x_c_passive - obj.x_free_passive_blue)^2+(y_c_passive-obj.y_free_passive_blue)^2);
            dist_5 = sqrt((obj.x_free_passive_blue - x_tendon_passive)^2+(obj.y_free_passive_blue-y_tendon_passive)^2);
            obj.alpha_passive_red = acos((dist_2^2+dist_1^2-dist_3^2)/(2*dist_1*dist_2));
            obj.alpha_passive_blue = acos((dist_2^2+dist_4^2-dist_5^2)/(2*dist_4*dist_2));
            if obj.red_alpha_passive_oversized == true
                obj.alpha_passive_red = 2*pi-obj.alpha_passive_red;
            end
            if obj.blue_alpha_passive_oversized == true
                obj.alpha_passive_blue = 2*pi-obj.alpha_passive_blue;
            end

%             x_active_zero = x_c_active + (r_active+obj.tendon_diameter/2) * cos(0);
%             y_active_zero = y_c_active + (r_active+obj.tendon_diameter/2) * sin(0);
%             dist_2 = sqrt((x_c_active - x_active_zero)^2+(y_c_passive-y_active_zero)^2);
%             dist_4 = sqrt((x_c_active - obj.x_free_active_blue)^2+(y_c_passive-obj.y_free_active_blue)^2);
%             dist_5 = sqrt((obj.x_free_active_blue - x_active_zero)^2+(obj.y_free_active_blue-y_active_zero)^2);
%             obj.alpha_active_blue = acos((dist_2^2+dist_4^2-dist_5^2)/(2*dist_4*dist_2));
            

            if obj.maxAngle_indicator == 'r'
                red_angle = obj.maxAngle;
                blue_angle = -obj.minAngle;
            elseif obj.maxAngle_indicator == 'b'
                red_angle = -obj.minAngle;
                blue_angle = obj.maxAngle;
            end

            %using the angles on the active and passive pulley, calculate
            %the total tendon length
            l_active = r_active*(pi/2);
            l_passive_red = r_passive*(obj.alpha_passive_red+red_angle);
            l_passive_blue = r_passive*(obj.alpha_passive_blue+blue_angle);
            %l_total_ = l_active + l_free + l_passive;
            red_tendon = l_active + l_free_3 + l_passive_red;
            blue_tendon = l_active + l_free_3 + l_passive_blue;
            obj.red_tendon_length = red_tendon;
            obj.blue_tendon_length = blue_tendon;
        end

        function result = visualize(obj)
            %visualization
            f = figure("Name",obj.name);
            f.Position = [0,0,850,700];
            hold on;
            line_width = 3;
            marker_size = 15;
            font_size = 18;

            base_angle = -alpha_passive_1-theta_3;
            top_inc = base_angle + top_angle;
            bot_inc = base_angle - bot_angle;
            x_tendon_attachment = x_c_passive + r_passive * cos(base_angle);
            y_tendon_attachment = y_c_passive + r_passive * sin(base_angle);
            x_top_max = x_c_passive + r_passive * cos(top_inc);
            y_top_max = y_c_passive + r_passive * sin(top_inc);
            x_bot_max = x_c_passive + r_passive * cos(bot_inc);
            y_bot_max = y_c_passive + r_passive * sin(bot_inc);

            x_alpha_passive_point_1 = x_c_passive + r_passive * cos(-alpha_passive_1-theta_3);
            y_alpha_passive_point_1 = y_c_passive + r_passive * sin(-alpha_passive_1-theta_3);
            x_alpha_passive_point_2 = x_c_passive + r_passive * cos(-alpha_passive_1-maxAngle-theta_3);
            y_alpha_passive_point_2 = y_c_passive + r_passive * sin(-alpha_passive_1-maxAngle-theta_3);
            x_alpha_passive_point_3 = x_c_passive + r_passive * cos(alpha_passive_2-minAngle+theta_2);
            y_alpha_passive_point_3 = y_c_passive + r_passive * sin(alpha_passive_2-minAngle+theta_2);
            x_alpha_passive_point_4 = x_c_passive + r_passive * cos(alpha_passive_2+theta_2);
            y_alpha_passive_point_4 = y_c_passive + r_passive * sin(alpha_passive_2+theta_2);

            passive_circle = nsidedpoly(1000, 'Center', [x_c_passive y_c_passive], 'Radius', r_passive);
            active_circle = nsidedpoly(1000, 'Center', [x_c_active y_c_active], 'Radius', r_active);
            passive_circle_plot = plot(passive_circle, 'FaceColor', "#D95319",'LineWidth',line_width);
            %passive_circle_plot.FaceColor
            
            active_circle_plot = plot(active_circle, 'FaceColor', "#EDB120",'LineWidth',line_width);

            %EXTRA VISUALS FOR THE PAPER BEGIN
            plot([x_c_passive x_tendon_attachment], [y_c_passive y_tendon_attachment], 'k','LineWidth',line_width)
            plot([x_c_passive x_free_passive_2], [y_c_passive y_free_passive_2], 'k','LineWidth',line_width)
            plot([x_c_passive x_top_max], [y_c_passive y_top_max], 'k','LineWidth',line_width)
            text(x_c_passive+3,y_c_passive,'c_{passive}','FontSize',font_size)
            text(x_c_active-2,y_c_active-5,'c_{active}','FontSize',font_size)
            text(x_tendon_attachment+2, y_tendon_attachment-3,'t_{passive}','FontSize',font_size)
            text(x_free_passive_2, y_free_passive_2+7, 'f_{passive}','FontSize',font_size)
            text(x_free_active_2+1, y_free_active_2+5, 'f_{active}','FontSize',font_size)

            %x2=x+(L*cos(alpha));
            %y2=y+(L*sin(alpha));
            %xx = r*cos(th); yy = r*sin(th);
            %plot([x x2],[y y2])
            
            a_p = theta_2:pi/90:(alpha_passive_2+theta_2);
            x_alpha_passive = x_c_passive + 5 * cos(a_p);
            y_alpha_passive = y_c_passive + 5 * sin(a_p);
            plot(x_alpha_passive, y_alpha_passive, "Color",'#008000','LineWidth',line_width)
            text(x_c_passive-24, y_c_passive+5, '\alpha_{passive}', 'Color','#008000','FontSize',font_size)

            q_m = theta_2+alpha_passive_2:pi/90:alpha_passive_2+theta_2+top_angle;
            x_q_max = x_c_passive + 5 * cos(q_m);
            y_q_max = y_c_passive + 5 * sin(q_m);
            plot(x_q_max, y_q_max, "Color",'#CC0000','LineWidth',line_width)
            text(x_c_passive-10, y_c_passive-7, 'q_{max}', 'Color','#CC0000','FontSize',font_size)
            
            %EXTRA VISUALS FOR THE PAPER END

            if y_free_passive_1 > y_free_passive_2
                plot(x_free_passive_1,y_free_passive_1,'rX','LineWidth',line_width,'MarkerSize',marker_size)
                plot(x_free_active_1,y_free_active_1,'rX','LineWidth',line_width,'MarkerSize',marker_size)
                plot(x_free_active_2,y_free_active_2, 'bX','LineWidth',line_width,'MarkerSize',marker_size)
                plot(x_free_passive_2,y_free_passive_2, 'bX','LineWidth',line_width,'MarkerSize',marker_size)
                plot([x_free_passive_1 x_free_active_1], [y_free_passive_1 y_free_active_1],'r','LineWidth',line_width)
                plot([x_free_passive_2 x_free_active_2], [y_free_passive_2 y_free_active_2],'b','LineWidth',line_width)
            else
                plot(x_free_passive_1,y_free_passive_1,'bX','LineWidth',line_width,'MarkerSize',marker_size)
                plot(x_free_active_1,y_free_active_1,'bX','LineWidth',line_width,'MarkerSize',marker_size)
                plot(x_free_active_2,y_free_active_2, 'rX','LineWidth',line_width,'MarkerSize',marker_size)
                plot(x_free_passive_2,y_free_passive_2, 'rX','LineWidth',line_width,'MarkerSize',marker_size)
                plot([x_free_passive_1 x_free_active_1], [y_free_passive_1 y_free_active_1],'b','LineWidth',line_width)
                plot([x_free_passive_2 x_free_active_2], [y_free_passive_2 y_free_active_2],'r','LineWidth',line_width)
            end
            %plot(x_tendon_passive, y_tendon_passive, 'gX')
            %plot(x_c_passive,y_c_passive+r_passive,'y*')
            %plot(x_c_passive,y_c_passive-r_passive,'y*')
            %plot(x_c_passive+r_passive*cos(-theta_3), y_c_passive+r_passive*sin(-theta_3), 'yX')
            %plot(x_alpha_passive_point_1, y_alpha_passive_point_1, 'gX')
            %plot(x_alpha_passive_point_2, y_alpha_passive_point_2, 'rX')
            %plot(x_alpha_passive_point_3, y_alpha_passive_point_3, 'bX')
            %plot(x_alpha_passive_point_4, y_alpha_passive_point_4, 'b*')
            plot(x_c_active, y_c_active, 'k+','LineWidth',line_width,'MarkerSize',marker_size)
            plot(x_c_passive, y_c_passive, 'k+','LineWidth',line_width,'MarkerSize',marker_size)
            plot(x_tendon_attachment, y_tendon_attachment, 'g+','LineWidth',line_width,'MarkerSize',marker_size)
            %plot(-73.472, -344.582, 'rO')
            plot(x_top_max,y_top_max,'r+','LineWidth',line_width,'MarkerSize',marker_size)
            plot(x_bot_max, y_bot_max,'b+','LineWidth',line_width,'MarkerSize',marker_size)

            


            leg = legend('Passive pulley', 'Active pulley', '', '', '','','', 'Tendon Free Position', '', 'Tendon Free Position', '', 'Tendon', 'Tendon','Pulley Center Position', '','Tendon Attachment Position','Red Tendon Max Position', 'Blue Tendon Max Position');
            leg.Location = 'best';
            %legend
            axis equal
            axis off
        end

        function [red_tendon, blue_tendon] = calcTendonLength(obj)
            %rotate the 3D coordinates to be aligned in 2D
            [new_x_active_pos, new_y_active_pos, new_z_active_pos] = obj.z_rot(obj.x_active_pos, obj.y_active_pos, obj.z_active_pos, obj.z_angle);
            [new_x_passive_pos, new_y_passive_pos, new_z_passive_pos] = obj.z_rot(obj.x_passive_pos,obj.y_passive_pos,obj.z_passive_pos,obj.z_angle);
            [new_x_tendon_pos, new_y_tendon_pos, new_z_tendon_pos] = obj.z_rot(obj.x_tendon_pos,obj.y_tendon_pos,obj.z_tendon_pos,obj.z_angle);

            %reassigning parameters into a new x/y coordinate system
            obj.x_2D_active_center = obj.coordinate_assignment(new_x_active_pos, new_y_active_pos, new_z_active_pos, obj.x_coordinate_id);
            obj.y_2D_active_center = obj.coordinate_assignment(new_x_active_pos, new_y_active_pos, new_z_active_pos, obj.y_coordinate_id);
            obj.x_2D_passive_center = obj.coordinate_assignment(new_x_passive_pos, new_y_passive_pos, new_z_passive_pos, obj.x_coordinate_id);
            obj.y_2D_passive_center = obj.coordinate_assignment(new_x_passive_pos, new_y_passive_pos, new_z_passive_pos, obj.y_coordinate_id);
            obj.x_2D_tendon_pos = obj.coordinate_assignment(new_x_tendon_pos, new_y_tendon_pos, new_z_tendon_pos, obj.x_coordinate_id);
            obj.y_2D_tendon_pos = obj.coordinate_assignment(new_x_tendon_pos, new_y_tendon_pos, new_z_tendon_pos, obj.y_coordinate_id);

            %calculating the tendon lengths
            [red_tendon, blue_tendon] = obj.calc_tendon_length((obj.r_active+obj.tendon_diameter/2), (obj.r_passive+obj.tendon_diameter/2));
        end
     
    end
end
