CREATE VIEW dbo.ViewExecutionRules
AS
SELECT ExecutionRule.ExecutionRuleID,
       ExecutionRule.Name,
       ExecutionRule.Definition,
       '[' + [Database].Name + '].[' + [Schema].Name + '].[' + [Table].Name + ']' AS [Table],
       ExecutionRuleType.Name AS [ExecutionRuleType],
       ExecutionRuleType.Description AS [ExecutionRuleTypeDescription],
       ExecutionRule.Enabled,
       ExecutionRule.Modified
FROM dbo.ExecutionRule ExecutionRule
    INNER JOIN dbo.ExecutionRuleType ExecutionRuleType
        ON ExecutionRuleType.ExecutionRuleTypeID = ExecutionRule.ExecutionRuleTypeID
    INNER JOIN dbo.[Table] [Table]
        ON [Table].TableID = ExecutionRule.TableID
    INNER JOIN dbo.[Schema] [Schema]
        ON [Schema].SchemaID = [Table].SchemaID
    INNER JOIN dbo.[Database] [Database]
        ON [Database].DatabaseID = [Schema].DatabaseID;