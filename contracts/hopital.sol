// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";


contract HospitalSystem {
    address public hospitalAddress;
    address public admin;

    // Define the Patient struct with relevant fields
    struct Patient {
        string name;
        uint age;
        string gender;
        address patientAddress;
        string contactDetails;
        address hospitalAddress;
    }

    // Map patient addresses to Patient structs
    mapping (address => Patient) public patients;

    // Define the Appointment struct with relevant fields
    struct Appointment {
        address patientAddress;
        bool paid;
        bool completed;
        string doctorName;
        uint256 _dateTime;
    }

    // Map appointment IDs to Appointment structs
    mapping (bytes32 => Appointment) public appointments;

    // Define the Billing struct with relevant fields
    struct Billing {
        address patientAddress;
        uint256 patientId;
        uint256 billingId;
        uint256 procedureId;
        uint amountDue;
        uint256 date;
        uint256 time;

    }

    // Map billing IDs to Billing structs
    mapping (bytes32 => Billing) public billing;

    // Define the MedicalRecord struct with relevant fields
    struct MedicalRecord {
        address patientAddress;
        string diagnosis;
        string treatment;
        uint date;
    }

    // Map medical record IDs to MedicalRecord structs
    mapping (bytes32 => MedicalRecord) public medicalRecords;

    // Define the Insurance struct with relevant fields
    struct Insurance {
        address patientAddress;
        string insuranceProvider;
        string policyNumber;
        uint date;
    }

    // Map insurance verification IDs to Insurance structs
    mapping (bytes32 => Insurance) public insuranceVerification;

    // Doctor struct to represent a doctor
    struct Doctor {
        uint id;
        string name;
        string specialty;
        address account;
    }

    // Mapping of doctor IDs to doctor structs
    mapping(uint => Doctor) public doctors;
     

    // Struct to represent a token payment
    struct TokenPayment {
        address patientAddress;
        uint amount;
        uint date;
    }

    // Mapping to keep track of all token payments
    mapping(bytes32 => TokenPayment) tokenPayments;



    // Set the hospitalAddress to the address of the contract creator
    constructor() {
        hospitalAddress = msg.sender;
    }


    event patientRegistered(
        string name,
        address patientAddress,
        uint256 age,
        string contactDetails
    );


    function registerPatient(
        string memory name,
        address patientAddress,
        uint256 age,
        string memory contactDetails
    ) public {
        // Check if the patient address is valid.
        require(patientAddress != address(0), "Invalid patient address");

        // Check if the patient address is not already registered.
        require(patients[patientAddress].patientAddress == address(0), "Patient already registered");

        // Create a new patient record.
        Patient memory newPatient = Patient(name, age, "", patientAddress, contactDetails, address(0));
        patients[patientAddress] = newPatient;

        // Emit an event to notify other contracts of the new patient registration.
        emit patientRegistered(name, patientAddress, age, contactDetails);
    }

    // This function takes a bytes32 variable as input and returns a string.
    function bytes32ToString(bytes32 _bytes32) public pure returns (string memory) {
        // Initialize a counter to 0.
        uint8 i = 0;
        // Loop through the first 32 bytes of the bytes32 variable, or until a null byte is encountered.
        while (i < 32 && _bytes32[i] != 0) {
            i++;
        }
        // Create a new bytes array with a length of i.
        bytes memory bytesArray = new bytes(i);
        // Loop through the first 32 bytes of the bytes32 variable, or until a null byte is encountered.
        for (i = 0; i < 32 && _bytes32[i] != 0; i++) {
            // Assign each byte of the bytes32 variable to the corresponding index in the bytes array.
            bytesArray[i] = _bytes32[i];
        }
        // Convert the bytes array to a string and return it.
        return string(bytesArray);
    }

    // Event to notify that an appointment has been scheduled
    event AppointmentScheduled(
        address indexed patientAddress, // Address of the patient who scheduled the appointment
        string appointmentId, // ID of the appointment that was scheduled
        uint256 dateTime // Date and time of the appointment
    );



    // Function to schedule a new appointment
    function scheduleAppointment(
        address _patientAddress, // Address of the patient who is scheduling the appointment
        string memory _doctorName, // Name of the doctor that the patient is scheduling the appointment with
        uint256 _dateTime // Date and time of the appointment
    ) public {
        // Ensure only the hospital can schedule appointments
        require(msg.sender == hospitalAddress, "Only the hospital can schedule an appointment.");

        // Generate a unique ID for the appointment
        bytes32 appointmentId = keccak256(abi.encodePacked(_patientAddress, _dateTime, block.timestamp));

        // Create a new appointment and add it to the appointments mapping
        Appointment memory newAppointment = Appointment(_patientAddress, false, false, _doctorName, _dateTime);
        appointments[appointmentId] = newAppointment;

        // Emit an event to notify that an appointment has been scheduled
        emit AppointmentScheduled(_patientAddress, bytes32ToString(appointmentId), _dateTime);
    }

    // Define the event to log when an appointment is confirmed
    event AppointmentConfirmed (
        uint indexed appointmentId
    );

    function confirmAppointment(
    string memory patientName, 
    string memory doctorName, 
    uint appointmentDate, 
    uint appointmentTime
    ) public {
        // Generate a unique ID for the appointment
        bytes32 appointmentId = keccak256(abi.encodePacked(patientName, doctorName, appointmentDate, appointmentTime));

        // Create an instance of the Appointment struct with the given details
        Appointment memory appointment = Appointment({
            patientName: patientName,
            doctorName: doctorName,
            appointmentDate: appointmentDate,
            appointmentTime: appointmentTime,
            confirmed: true
        });

        // Add the appointment to the appointments mapping
        appointments[appointmentId] = appointment;
        
        // Emit an event to indicate that the appointment has been confirmed
        emit AppointmentConfirmed(appointmentId);
    }


    // Event emitted when a new billing is created
    event createBilling(
        address patientAddress, // Address of the patient being billed
        bytes32 billingId, // Unique ID of the billing
        uint amountDue, // Amount due on the billing
        uint256 date // Date the billing was created
    );


    // Function to create a new billing for a patient
    function patientBilling(
        address patientAddress, 
        uint amountDue, 
        uint256 date
        ) public {
        require(msg.sender == hospitalAddress, "Only the hospital can create a billing.");

        // Generate a unique ID for the billing
        bytes32 billingId = keccak256(abi.encodePacked(patientAddress, date));

        // Create a new billing and add it to the billing mapping
        Billing storage patientBillingStorage = billing[billingId];
        patientBillingStorage.patientAddress = patientAddress;
        patientBillingStorage.amountDue = amountDue;
        patientBillingStorage.date = date;

        // Emit the createBilling event
        emit createBilling(patientAddress, billingId, amountDue, date);
    }


    // Function to add a new doctor
    function addDoctor(uint _id, string memory _name, string memory _specialty, address _account) public onlyAdmin {
        doctors[_id] = Doctor(_id, _name, _specialty, _account);
    }


    // Function to update an existing doctor
    function updateDoctor(uint _id, string memory _name, string memory _specialty) public onlyAdmin {
        doctors[_id].name = _name;
        doctors[_id].specialty = _specialty;
    }
    

    // Function to remove a doctor
    function removeDoctor(uint _id) public onlyAdmin {
        delete doctors[_id];
    }

    // Modifier to restrict access to admin users
    modifier onlyAdmin {
        require(msg.sender == admin, "Only admin users can perform this action");
        _;
    }

     // Constructor to set the admin user
    constructor() {
        admin = msg.sender;
        }

    function createMedicalRecord(
        address patientAddress,
        string memory diagnosis,
        string memory treatment,
        uint date
    ) public {
        // Check if the patient address is valid.
        require(patientAddress != address(0), "Invalid patient address");

        // Generate a unique ID for the medical record
        bytes32 recordId = keccak256(abi.encodePacked(patientAddress, date));

        // Create a new medical record and add it to the medicalRecords mapping
        MedicalRecord memory newRecord = MedicalRecord(patientAddress, diagnosis, treatment, date);
        medicalRecords[recordId] = newRecord;
    }


    function verifyInsurance(
        address patientAddress,
        string memory insuranceProvider,
        string memory policyNumber,
        uint date
    ) public {
        // Check if the patient address is valid.
        require(patientAddress != address(0), "Invalid patient address");

        // Generate a unique ID for the insurance verification
        bytes32 verificationId = keccak256(abi.encodePacked(patientAddress, date));

        // Create a new insurance verification record and add it to the insuranceVerification mapping
        Insurance memory newVerification = Insurance(patientAddress, insuranceProvider, policyNumber, date);
        insuranceVerification[verificationId] = newVerification;
    }


   // Function to allow patients to pay their bills using ERC20 tokens
    function payBillWithTokens(bytes32 billingId, uint amount) public {
        // Retrieve the billing from the billing mapping
        Billing storage bill = billing[billingId];

        // Transfer the token amount from the patient to the hospital
        require(token.transferFrom(msg.sender, address(this), amount), "Token transfer failed");

        // Generate a unique ID for the token payment
        bytes32 paymentId = keccak256(abi.encodePacked(msg.sender, billingId, amount, now));

        // Create a new token payment and add it to the tokenPayments mapping
        TokenPayment memory newPayment = TokenPayment(msg.sender, amount, now);
        tokenPayments[paymentId] = newPayment;

        // Update the billing amount and paid status
        bill.amountPaid += amount;
        if (bill.amountPaid >= bill.totalAmount) {
            bill.isPaid = true;
        }
    }


}