import 'package:efeone_mobile/utilities/constants.dart';
import 'package:efeone_mobile/widgets/cust_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:efeone_mobile/controllers/leave.dart';

class LeaveApplicationScreen extends StatelessWidget {
  const LeaveApplicationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller =
        Provider.of<LeaveRequestProvider>(context, listen: false);
    controller.loadSharedPrefs();

    return WillPopScope(
      onWillPop: () async {
        controller.clearValues();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Image.asset('assets/images/efeone Logo.png', width: 90),
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: FutureBuilder(
            future: controller.fetchLeaveDetails(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: primaryColor),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                );
              } else {
                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Consumer<LeaveRequestProvider>(
                      builder: (context, provider, child) {
                        return Form(
                          key: provider.formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  custom_text(
                                    text: 'Apply for Leave',
                                    fontSize: 23,
                                    color: primaryColor,
                                  ),
                                ],
                              ),
                              _buildLabeledContainer(
                                  'Employee ID', provider.empid.toString()),
                              _buildLabeledContainer(
                                  'Employee Name', provider.empname.toString()),
                              _buildDropdownField(provider, controller),
                              _buildDatePickers(provider, context),
                              _buildHalfDayCheckbox(provider),
                              if (provider.isHalfDay)
                                _buildHalfDayDateField(provider, context),
                              if (provider.dateValidationError != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    provider.dateValidationError!,
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                ),
                              _buildTextField(
                                  'Reason', provider.reasonController),
                              const SizedBox(height: 25),
                              _buildSubmitButton(provider, controller, context),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLabeledContainer(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12.0),
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(value, style: const TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField(
      LeaveRequestProvider provider, LeaveRequestProvider controller) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Leave Type',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonFormField<String>(
              value: provider.leaveType,
              decoration: const InputDecoration(border: InputBorder.none),
              items: controller.leaveTypes.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: provider.setLeaveType,
              validator: (value) => value == null || value.isEmpty
                  ? 'Please select Leave Type'
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePickers(
      LeaveRequestProvider provider, BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: _buildDateField('Start Date', provider.startDate,
                provider.pickStartDate, context)),
        const SizedBox(width: 16),
        Expanded(
            child: _buildDateField(
                'End Date', provider.endDate, provider.pickEndDate, context)),
      ],
    );
  }

  Widget _buildDateField(String label, DateTime? date,
      Future<void> Function(BuildContext) onTap, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => onTap(context),
            child: AbsorbPointer(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  date != null
                      ? "${date.day}/${date.month}/${date.year}"
                      : 'DD / MM / YY',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHalfDayCheckbox(LeaveRequestProvider provider) {
    return Row(
      children: [
        Checkbox(
          value: provider.isHalfDay,
          onChanged: (value) {
            provider.setHalfDay(value ?? false);
          },
        ),
        const Text('Half Day', style: TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildHalfDayDateField(
      LeaveRequestProvider provider, BuildContext context) {
    return _buildDateField('Half Day Date', provider.halfDayDate,
        provider.pickHalfDayDate, context);
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextFormField(
              controller: controller,
              maxLines: 4,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Please enter reason',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(
    LeaveRequestProvider provider,
    LeaveRequestProvider controller,
    BuildContext context,
  ) {
    return Center(
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
          ),
          onPressed: () {
            if (provider.formKey.currentState?.validate() == true) {
              if (provider.validateDates()) {
                final leaveType = controller.leaveType!;
                final fromDate = controller.startDate!.toIso8601String();
                final toDate = controller.endDate!.toIso8601String();
                final halfDay = controller.isHalfDay ? 1 : 0;
                final halfDayDate = controller.isHalfDay
                    ? controller.halfDayDate!.toIso8601String()
                    : '';
                final totalLeaveDays = controller.calculateTotalLeaveDays();
                final reason = controller.reasonController.text;
                final leaveApprover = controller.approver!;
                const followViaEmail = 1;
                final postingDate = DateTime.now().toIso8601String();
                controller.submitLeave(
                  leaveType,
                  fromDate,
                  toDate,
                  halfDay,
                  halfDayDate,
                  totalLeaveDays,
                  reason,
                  leaveApprover,
                  followViaEmail,
                  postingDate,
                  context,
                );
              }
            }
          },
          child: const custom_text(
            text: "Submit",
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
