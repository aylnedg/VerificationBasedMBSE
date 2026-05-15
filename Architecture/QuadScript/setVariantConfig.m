function setVariantConfig(configName)
%SETVARIANTCONFIG Switch UAV mission configuration.
%   Configurations:
%     'Nominal_MAVLink'     - MAVLink comms, no threat
%     'Adversarial_MAVLink' - MAVLink comms, active threat
%     'Custom_NoThreat'     - Custom protocol, no threat
%
%   Usage: setVariantConfig('Nominal_MAVLink')

dd  = Simulink.data.dictionary.open('QuadData.sldd');
sec = getSection(dd, 'Design Data');

switch configName
  case 'Nominal_MAVLink'
    setValue(getEntry(sec,'varComms'),  1);
    setValue(getEntry(sec,'varThreat'), 0);
    disp('[VariantConfig] Nominal_MAVLink active')

  case 'Adversarial_MAVLink'
    setValue(getEntry(sec,'varComms'),  1);
    setValue(getEntry(sec,'varThreat'), 1);
    disp('[VariantConfig] Adversarial_MAVLink active')

  case 'Custom_NoThreat'
    setValue(getEntry(sec,'varComms'),  0);
    setValue(getEntry(sec,'varThreat'), 0);
    disp('[VariantConfig] Custom_NoThreat active')

  otherwise
    error('Unknown config: %s', configName)
end

saveChanges(dd);
end
