// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HospitalSystem {
    struct Patient {
        string name;
        uint age;
        address Address;
        string contactDetails;
    }

    mapping (address => Patient) public patients;

    struct Appointment {
        address patientAddress;
        string doctorName;
        uint dateTime;
    }

    mapping (bytes32 => Appointment) public appointments;

    struct Billing {
        address patientAddress;
        uint amountDue;
        uint date;
    }

    mapping (bytes32 => Billing) public billing;

    struct MedicalRecord {
        address patientAddress;
        string diagnosis;
        string treatment;
        uint date;
    }

    mapping (bytes32 => MedicalRecord) public medicalRecords;

    struct Insurance {
        address patientAddress;
        string insuranceProvider;
        string policyNumber;
        uint date;
    }

    mapping (bytes32 => Insurance) public insuranceVerification;

    function registerPatient(string memory _name, uint _age, address _Address, string memory _contactDetails) public {
        Patient memory newPatient = Patient(_name, _age, _Address, _contactDetails);
        patients[msg.sender] = newPatient;
    }

    function scheduleAppointment(address _patientAddress, string memory _doctorName, uint _dateTime) public {
        bytes32 appointmentId = keccak256(abi.encodePacked(_patientAddress, _dateTime));
        Appointment memory newAppointment = Appointment(_patientAddress, _doctorName, _dateTime);
        appointments[appointmentId] = newAppointment;
    }

    function createBilling(address _patientAddress, uint _amountDue, uint _date) public {
        bytes32 billingId = keccak256(abi.encodePacked(_patientAddress, _date));
        Billing memory newBilling = Billing(_patientAddress, _amountDue, _date);
        billing[billingId] = newBilling;
    }

    function createMedicalRecord(address _patientAddress, string memory _diagnosis, string memory _treatment, uint _date) public {
        bytes32 recordId = keccak256(abi.encodePacked(_patientAddress, _date));
        MedicalRecord memory newRecord = MedicalRecord(_patientAddress, _diagnosis, _treatment, _date);
        medicalRecords[recordId] = newRecord;
    }

    function verifyInsurance(address _patientAddress, string memory _insuranceProvider, string memory _policyNumber, uint _date) public {
        bytes32 verificationId = keccak256(abi.encodePacked(_patientAddress, _date));
        Insurance memory newVerification = Insurance(_patientAddress, _insuranceProvider, _policyNumber, _date);
        insuranceVerification[verificationId] = newVerification;
    }
}