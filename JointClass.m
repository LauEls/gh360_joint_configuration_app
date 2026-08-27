classdef JointClass < handle
    %JOINTCLASS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        name
        minAngle
        maxAngle
        r_active
        r_passive
        r_middle
        tendon_diameter
        number_tendon_attachments
        number_pulleys
        left
        right
        left_pulley_config = false %true if pulley config has been calculated
        right_pulley_config = false %true if pulley config has been calculated
        right_pos_actuator_id = 0
        right_neg_actuator_id = 0
        left_pos_actuator_id = 0
        left_neg_actuator_id = 0

        inner_active_mounting_length = 0
        outer_active_mounting_length = 0
        passive_mounting_length = 0
        sleeve_assembly_extra = 0
        sleeve_cutting_ratio = 1.0
%         red_tendon_length
%         blue_tendon_length
    end
    
    methods
        function out = addNormalSides(obj)
            obj.left.tendons = TendonClass;
            obj.left.tendons.minAngle = obj.minAngle;
            obj.left.tendons.maxAngle = obj.maxAngle;
            obj.left.tendons.r_active = obj.r_active;
            obj.left.tendons.r_passive = obj.r_passive;
            obj.left.tendons.tendon_diameter = obj.tendon_diameter;
            obj.left.tendons.name = 'Left Side';
            
            obj.right.tendons = TendonClass;
            obj.right.tendons.minAngle = obj.minAngle;
            obj.right.tendons.maxAngle = obj.maxAngle;
            obj.right.tendons.r_active = obj.r_active;
            obj.right.tendons.r_passive = obj.r_passive;
            obj.right.tendons.tendon_diameter = obj.tendon_diameter;
            obj.right.tendons.name = 'Right Side';

            obj.left.inner_pulley = PulleyClass;
            obj.left.inner_pulley.r_active = obj.r_active;
            obj.left.inner_pulley.r_passive = obj.r_passive;
            obj.left.inner_pulley.tendon_diameter = obj.tendon_diameter;
            obj.left.inner_pulley.minAngle = obj.minAngle;
            obj.left.inner_pulley.maxAngle = obj.maxAngle;
            obj.left.inner_pulley.pulley_id = 'i';
            obj.left.outer_pulley = PulleyClass;
            obj.left.outer_pulley.r_active = obj.r_active;
            obj.left.outer_pulley.r_passive = obj.r_passive;
            obj.left.outer_pulley.tendon_diameter = obj.tendon_diameter;
            obj.left.outer_pulley.minAngle = obj.minAngle;
            obj.left.outer_pulley.maxAngle = obj.maxAngle;
            obj.left.outer_pulley.pulley_id = 'o';

            obj.right.inner_pulley = PulleyClass;
            obj.right.inner_pulley.r_active = obj.r_active;
            obj.right.inner_pulley.r_passive = obj.r_passive;
            obj.right.inner_pulley.tendon_diameter = obj.tendon_diameter;
            obj.right.inner_pulley.minAngle = obj.minAngle;
            obj.right.inner_pulley.maxAngle = obj.maxAngle;
            obj.right.inner_pulley.pulley_id = 'i';
            obj.right.outer_pulley = PulleyClass;
            obj.right.outer_pulley.r_active = obj.r_active;
            obj.right.outer_pulley.r_passive = obj.r_passive;
            obj.right.outer_pulley.tendon_diameter = obj.tendon_diameter;
            obj.right.outer_pulley.minAngle = obj.minAngle;
            obj.right.outer_pulley.maxAngle = obj.maxAngle;
            obj.right.outer_pulley.pulley_id = 'o';

            if obj.name == "Shoulder Yaw" || obj.name == "Shoulder Roll"
                obj.right.inner_pulley.pulley_type = 's';
                obj.right.outer_pulley.pulley_type = 's';
                obj.left.inner_pulley.pulley_type = 's';
                obj.left.outer_pulley.pulley_type = 's';
            else
                obj.right.inner_pulley.pulley_type = 'a';
                obj.right.outer_pulley.pulley_type = 'a';
                obj.left.inner_pulley.pulley_type = 'a';
                obj.left.outer_pulley.pulley_type = 'a';
            end
        end

        function out = addShoulderPitchSides(obj)
            obj.left.tendons = ShoulderPitchTendonClass;
            obj.left.tendons.minAngle = obj.minAngle;
            obj.left.tendons.maxAngle = obj.maxAngle;
            obj.left.tendons.r_active = obj.r_active;
            obj.left.tendons.r_passive = obj.r_passive;
            obj.left.tendons.r_middle = obj.r_middle;
            obj.left.tendons.tendon_diameter = obj.tendon_diameter;
            obj.left.tendons.name = 'Left Side';

            obj.right.tendons = ShoulderPitchTendonClass;
            obj.right.tendons.minAngle = obj.minAngle;
            obj.right.tendons.maxAngle = obj.maxAngle;
            obj.right.tendons.r_active = obj.r_active;
            obj.right.tendons.r_passive = obj.r_passive;
            obj.right.tendons.r_middle = obj.r_middle;
            obj.right.tendons.tendon_diameter = obj.tendon_diameter;
            obj.right.tendons.name = 'Right Side';

            obj.left.inner_pulley = PulleyClass;
            obj.left.inner_pulley.r_active = obj.r_active;
            obj.left.inner_pulley.r_passive = obj.r_passive;
            obj.left.inner_pulley.tendon_diameter = obj.tendon_diameter;
            obj.left.inner_pulley.minAngle = obj.minAngle;
            obj.left.inner_pulley.maxAngle = obj.maxAngle;
            obj.left.inner_pulley.pulley_id = 'i';
            obj.left.inner_pulley.pulley_type = 's';
            obj.left.outer_pulley = PulleyClass;
            obj.left.outer_pulley.r_active = obj.r_active;
            obj.left.outer_pulley.r_passive = obj.r_passive;
            obj.left.outer_pulley.tendon_diameter = obj.tendon_diameter;
            obj.left.outer_pulley.minAngle = obj.minAngle;
            obj.left.outer_pulley.maxAngle = obj.maxAngle;
            obj.left.outer_pulley.pulley_id = 'o';
            obj.left.outer_pulley.pulley_type = 's';

            obj.right.inner_pulley = PulleyClass;
            obj.right.inner_pulley.r_active = obj.r_active;
            obj.right.inner_pulley.r_passive = obj.r_passive;
            obj.right.inner_pulley.tendon_diameter = obj.tendon_diameter;
            obj.right.inner_pulley.minAngle = obj.minAngle;
            obj.right.inner_pulley.maxAngle = obj.maxAngle;
            obj.right.inner_pulley.pulley_id = 'i';
            obj.right.inner_pulley.pulley_type = 's';
            obj.right.outer_pulley = PulleyClass;
            obj.right.outer_pulley.r_active = obj.r_active;
            obj.right.outer_pulley.r_passive = obj.r_passive;
            obj.right.outer_pulley.tendon_diameter = obj.tendon_diameter;
            obj.right.outer_pulley.minAngle = obj.minAngle;
            obj.right.outer_pulley.maxAngle = obj.maxAngle;
            obj.right.outer_pulley.pulley_id = 'o';
            obj.right.outer_pulley.pulley_type = 's';
        end

        function out = addUpperarmRollSides(obj)
            obj.left.tendons = UpperarmRollTendonClass;
            obj.left.tendons.minAngle = obj.minAngle;
            obj.left.tendons.maxAngle = obj.maxAngle;
            obj.left.tendons.r_active = obj.r_active;
            obj.left.tendons.r_passive = obj.r_passive;
            obj.left.tendons.tendon_diameter = obj.tendon_diameter;
            obj.left.tendons.name = 'Left Side';

            obj.right.tendons = UpperarmRollTendonClass;
            obj.right.tendons.minAngle = obj.minAngle;
            obj.right.tendons.maxAngle = obj.maxAngle;
            obj.right.tendons.r_active = obj.r_active;
            obj.right.tendons.r_passive = obj.r_passive;
            obj.right.tendons.tendon_diameter = obj.tendon_diameter;
            obj.right.tendons.name = 'Right Side';

            obj.left.inner_pulley = PulleyClass;
            obj.left.inner_pulley.r_active = obj.r_active;
            obj.left.inner_pulley.r_passive = obj.r_passive;
            obj.left.inner_pulley.tendon_diameter = obj.tendon_diameter;
            obj.left.inner_pulley.minAngle = obj.minAngle;
            obj.left.inner_pulley.maxAngle = obj.maxAngle;
            obj.left.inner_pulley.pulley_id = 'i';
            obj.left.inner_pulley.pulley_type = 'a';
            obj.left.outer_pulley = PulleyClass;
            obj.left.outer_pulley.r_active = obj.r_active;
            obj.left.outer_pulley.r_passive = obj.r_passive;
            obj.left.outer_pulley.tendon_diameter = obj.tendon_diameter;
            obj.left.outer_pulley.minAngle = obj.minAngle;
            obj.left.outer_pulley.maxAngle = obj.maxAngle;
            obj.left.outer_pulley.pulley_id = 'o';
            obj.left.outer_pulley.pulley_type = 'a';

            obj.right.inner_pulley = PulleyClass;
            obj.right.inner_pulley.r_active = obj.r_active;
            obj.right.inner_pulley.r_passive = obj.r_passive;
            obj.right.inner_pulley.tendon_diameter = obj.tendon_diameter;
            obj.right.inner_pulley.minAngle = obj.minAngle;
            obj.right.inner_pulley.maxAngle = obj.maxAngle;
            obj.right.inner_pulley.pulley_id = 'i';
            obj.right.inner_pulley.pulley_type = 'a';
            obj.right.outer_pulley = PulleyClass;
            obj.right.outer_pulley.r_active = obj.r_active;
            obj.right.outer_pulley.r_passive = obj.r_passive;
            obj.right.outer_pulley.tendon_diameter = obj.tendon_diameter;
            obj.right.outer_pulley.minAngle = obj.minAngle;
            obj.right.outer_pulley.maxAngle = obj.maxAngle;
            obj.right.outer_pulley.pulley_id = 'o';
            obj.right.outer_pulley.pulley_type = 'a';
        end
        
%         function obj = JointClass(right_side,left_side)
%             %JOINTCLASS Construct an instance of this class
%             %   Detailed explanation goes here
%             obj.right_side = right_tendon;
%             obj.left_side = left_tendon;
%         end
        
%         function outputArg = method1(obj,inputArg)
%             %METHOD1 Summary of this method goes here
%             %   Detailed explanation goes here
%             outputArg = obj.Property1 + inputArg;
%         end
    end
end

