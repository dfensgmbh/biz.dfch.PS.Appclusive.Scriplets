select * from core.Node where Name = 'Test3';
select * from core.ExternalNode where NodeId = 635;
select * from core.ExternalNodeBag where ExternaldNodeId = 147

-- Node job
select * from core.Job where EntityKindId = 1 and RefId = 635
-- Worker job
--select * from core.Job where ParentId = 1504
-- Order item job
select * from core.Job where Id = 1502
-- Order item
select * from core.OrderItem where Id = 165
-- Order job
select * from core.Job where Id = 1501
-- Order
select * from core.[Order] where Id = 165
-- Approval job
select * from core.Job where EntityKindId = 5 and parentId = 1501
-- Approval
select * from core.Approval where Id = 165