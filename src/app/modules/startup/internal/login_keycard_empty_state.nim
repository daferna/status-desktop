type
  LoginKeycardEmptyState* = ref object of State

proc newLoginKeycardEmptyState*(flowType: FlowType, backState: State): LoginKeycardEmptyState =
  result = LoginKeycardEmptyState()
  result.setup(flowType, StateType.LoginKeycardEmpty, backState)

proc delete*(self: LoginKeycardEmptyState) =
  self.State.delete

method executePrimaryCommand*(self: LoginKeycardEmptyState, controller: Controller) =
  if self.flowType == FlowType.AppLogin:
    controller.runLoadAccountFlow(factoryReset = true)

method getNextSecondaryState*(self: LoginKeycardEmptyState, controller: Controller): State =
  return createState(StateType.WelcomeNewStatusUser, self.flowType, self)

method getNextTertiaryState*(self: LoginKeycardEmptyState, controller: Controller): State =
  return createState(StateType.WelcomeOldStatusUser, self.flowType, self)

method resolveKeycardNextState*(self: LoginKeycardEmptyState, keycardFlowType: string, keycardEvent: KeycardEvent, 
  controller: Controller): State =
  if self.flowType == FlowType.AppLogin:
    if keycardFlowType == ResponseTypeValueKeycardFlowResult and 
      keycardEvent.error.len > 0 and
      keycardEvent.error == ErrorConnection:
        controller.resumeCurrentFlowLater()
        return createState(StateType.KeycardPluginReader, FlowType.FirstRunNewUserNewKeycardKeys, self)
    if keycardFlowType == ResponseTypeValueInsertCard:
      return createState(StateType.KeycardInsertKeycard, FlowType.FirstRunNewUserNewKeycardKeys, self)