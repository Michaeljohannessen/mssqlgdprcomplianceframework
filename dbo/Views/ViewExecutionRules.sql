CREATE VIEW dbo.ViewExecutionRules
AS
SELECT ExecutionRule.ExecutionRuleID,
       ExecutionRule.Name,
       ExecutionRule.Definition,
       ExecutionRuleType.Name AS [ExecutionRuleType],
       ExecutionRule.Enabled,
       ExecutionRule.Modified
FROM dbo.ExecutionRule ExecutionRule
    INNER JOIN dbo.ExecutionRuleType ExecutionRuleType
        ON ExecutionRuleType.ExecutionRuleTypeID = ExecutionRule.ExecutionRuleTypeID;